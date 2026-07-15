import SwiftUI
import Combine
import ARKit
import SceneKit
import AVFoundation
import UIKit

@MainActor
final class FaceTrackingViewModel: ObservableObject {
    @Published var isSupported: Bool = true
    @Published var statusMessage: String = "초기화 중..."
    @Published var routine: [FaceAction] = FaceAction.defaultRoutine
    @Published var currentActionIndex: Int = 0
    @Published var isHolding: Bool = false
    @Published var isRoutineComplete: Bool = false
    @Published var isTransitioning: Bool = false // Added transition state
    @Published var cameraAuthorizationStatus: AVAuthorizationStatus = .notDetermined

    let session = ARSession()
    private let delegate = FaceSessionDelegate()
    private var wasHolding: Bool = false
    private var hasStartedSession: Bool = false

    // MARK: - Haptics
    // Light tap when the expression is recognized (guide image turns green),
    // heavy thump when an action completes and moves to the next one.
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Timing Control Properties
    private var holdStartTime: Date? // Time when user starts holding the expression
    private var lastCountTime: Date? // Time of last successful count

    // Minimum time the expression must be held to count as one rep
    private let minimumHoldDuration: TimeInterval = 0.25
    // Minimum interval between two counted reps
    private let cooldownDuration: TimeInterval = 0.4
    
    // Activation threshold that adjusts based on sensitivity setting
    // Higher sensitivity (1.0) = lower threshold (easier recognition)
    // Lower sensitivity (0.0) = higher threshold (more precise recognition)
    private var activationThreshold: CGFloat {
        let sensitivity = AppSettings.shared.faceDetectionSensitivity
        // Sensitivity 0.0 → threshold 0.6 (high, harder to detect)
        // Sensitivity 0.5 → threshold 0.4 (medium)
        // Sensitivity 1.0 → threshold 0.2 (low, easier to detect)
        return 0.6 - (sensitivity * 0.4)
    }

    var currentAction: FaceAction? {
        guard currentActionIndex < routine.count else { return nil }
        return routine[currentActionIndex]
    }

    init() {
        delegate.onEvent = { [weak self] event in
            self?.handle(event)
        }
        session.delegate = delegate
        
        // Check initial authorization status
        checkCameraAuthorization()
    }
    
    // MARK: - Camera Authorization
    func checkCameraAuthorization() {
        cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func requestCameraPermission() async {
        let status = await AVCaptureDevice.requestAccess(for: .video)
        cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status {
            statusMessage = "카메라 접근이 허용되었습니다"
        } else {
            statusMessage = "카메라 접근이 거부되었습니다"
        }
    }

    func start() {
        // Check if device supports face tracking
        guard ARFaceTrackingConfiguration.isSupported else {
            isSupported = false
            statusMessage = "이 기기에서는 얼굴 인식을 지원하지 않습니다"
            return
        }
        
        // Check camera authorization
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        guard authStatus == .authorized else {
            statusMessage = "카메라 권한이 필요합니다"
            return
        }

        // Prevent multiple starts
        guard !hasStartedSession else {
            statusMessage = "세션이 이미 실행 중입니다"
            return
        }

        statusMessage = "카메라 세션을 시작하는 중..."
        
        // Small delay to ensure view is ready
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            
            let config = ARFaceTrackingConfiguration()
            config.isLightEstimationEnabled = true
            
            // Start fresh session
            session.run(config, options: [.resetTracking, .removeExistingAnchors])
            hasStartedSession = true

            // Warm up haptic engines to minimize first-tap latency
            lightHaptic.prepare()
            heavyHaptic.prepare()

            statusMessage = "얼굴을 찾는 중..."
        }
    }

    func pause() {
        session.pause()
        hasStartedSession = false
    }

    func restartRoutine() {
        routine = FaceAction.defaultRoutine
        currentActionIndex = 0
        isRoutineComplete = false
        wasHolding = false
        isHolding = false
        isTransitioning = false
        
        // Reset timing control
        holdStartTime = nil
        lastCountTime = nil
        
        // Don't reset hasStartedSession - session is still running
    }

    private func handle(_ event: FaceSessionEvent) {
        switch event {
        case .faceUpdated(let blendShapes):
            statusMessage = "얼굴을 인식하는 중"
            detectActionRep(from: blendShapes)

        case .error(let message):
            statusMessage = "오류: \(message)"

        case .interrupted:
            statusMessage = "세션이 중단되었습니다"

        case .interruptionEnded:
            statusMessage = "세션을 재개하는 중..."
            // Don't auto-restart, let the user control it
            hasStartedSession = false
        }
    }

    private func detectActionRep(from blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        guard let action = currentAction, !isRoutineComplete, !isTransitioning else { return }

        let isActive = checkAnchorsActive(action, in: blendShapes)
        
        // MARK: - Holding Duration Check
        // When user starts holding the expression
        if isActive && !wasHolding {
            holdStartTime = Date()
            // Guide image turns green at this moment → light haptic feedback
            lightHaptic.impactOccurred()
            lightHaptic.prepare()
        }
        
        // When user releases the expression
        if wasHolding && !isActive {
            // Check 1: Minimum hold duration satisfied?
            guard let startTime = holdStartTime,
                  Date().timeIntervalSince(startTime) >= minimumHoldDuration else {
                // Expression was held too briefly, ignore this attempt
                wasHolding = isActive
                isHolding = isActive
                holdStartTime = nil
                return
            }
            
            // Check 2: Cooldown period passed since last count?
            if let lastTime = lastCountTime,
               Date().timeIntervalSince(lastTime) < cooldownDuration {
                // Still in cooldown period, ignore this attempt
                wasHolding = isActive
                isHolding = isActive
                holdStartTime = nil
                return
            }
            
            // All checks passed - proceed with counting
            lastCountTime = Date()
            holdStartTime = nil
            
            // Handle sub-steps if present
            if let subSteps = action.subSteps, action.currentSubStepIndex < subSteps.count {
                // Current sub-step completed → move to next sub-step
                routine[currentActionIndex].currentSubStepIndex += 1
                
                // Check if all sub-steps are completed
                if routine[currentActionIndex].currentSubStepIndex >= subSteps.count {
                    // One set completed → increase count and reset sub-step
                    routine[currentActionIndex].completedCount += 1
                    routine[currentActionIndex].currentSubStepIndex = 0
                    
                    if routine[currentActionIndex].isComplete {
                        advanceToNext()
                    }
                }
            } else {
                // Regular action without sub-steps
                routine[currentActionIndex].completedCount += 1
                if routine[currentActionIndex].isComplete {
                    advanceToNext()
                }
            }
        }
        
        // Reset hold start time if expression is released
        if !isActive && holdStartTime != nil {
            holdStartTime = nil
        }

        wasHolding = isActive
        isHolding = isActive
    }

    private func checkAnchorsActive(
        _ action: FaceAction,
        in blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]
    ) -> Bool {
        // Get anchors and mode to check
        let anchorsToCheck = action.currentAnchors
        let modeToUse = action.currentDetectionMode
        let excludedAnchors = action.currentExcludedAnchors
        
        // 1. Check required anchors
        let values = anchorsToCheck.compactMap { anchor in
            blendShapes[anchor].map { CGFloat(truncating: $0) }
        }
        guard values.count == anchorsToCheck.count else { return false }

        let requiredActive: Bool
        switch modeToUse {
        case .all:
            requiredActive = values.allSatisfy { $0 >= activationThreshold }
        case .any:
            requiredActive = values.contains { $0 >= activationThreshold }
        }
        
        // Return false if required conditions are not met
        guard requiredActive else { return false }
        
        // 2. Check excluded anchors (must be inactive)
        if !excludedAnchors.isEmpty {
            let excludedValues = excludedAnchors.compactMap { anchor in
                blendShapes[anchor].map { CGFloat(truncating: $0) }
            }
            
            // Return false if any excluded anchor is active
            let hasActiveExcluded = excludedValues.contains { $0 >= activationThreshold }
            if hasActiveExcluded {
                return false
            }
        }
        
        return true
    }

    private func advanceToNext() {
        wasHolding = false
        isHolding = false
        isTransitioning = true

        // An action just finished and is moving to the next → heavy haptic feedback
        heavyHaptic.impactOccurred()
        heavyHaptic.prepare()
        
        // Reset timing control for next action
        holdStartTime = nil
        lastCountTime = nil
        
        // Transition to next action after 1 second
        Task {
            try? await Task.sleep(for: .seconds(1))
            
            if currentActionIndex + 1 < routine.count {
                currentActionIndex += 1
            } else {
                isRoutineComplete = true
            }
            
            isTransitioning = false
        }
    }
    
    func skipCurrentAction() {
        guard !isRoutineComplete else { return }
        wasHolding = false
        isHolding = false
        if currentActionIndex + 1 < routine.count {
            currentActionIndex += 1
        } else {
            isRoutineComplete = true
        }
    }
}

