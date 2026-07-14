import SwiftUI
import ARKit
import SceneKit

struct MainView: View {
    @StateObject private var faceTrackingVM = FaceTrackingViewModel()
    @State private var instructionMessage: InstructionMessage?
    @State private var holdingMessage: InstructionMessage?
    @State private var showSettings = false
    @State private var showOnboarding = false
    @State private var isReadyToStart = false
    @Bindable private var settings = AppSettings.shared
    
    var body: some View {
        ZStack {
            if faceTrackingVM.isSupported {
                // Check camera authorization status
                switch faceTrackingVM.cameraAuthorizationStatus {
                case .authorized:
                    cameraView
                case .notDetermined:
                    permissionRequestView
                case .denied, .restricted:
                    permissionDeniedView
                @unknown default:
                    permissionRequestView
                }
            } else {
                unsupportedScreen
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
                .presentationDetents([.large])
                .interactiveDismissDisabled()
        }
        .onAppear {
            checkFirstLaunch()
        }
        .onChange(of: showOnboarding) { isShowing in
            // When onboarding is dismissed and camera is authorized, start the session
            if !isShowing && faceTrackingVM.cameraAuthorizationStatus == .authorized && isReadyToStart {
                faceTrackingVM.start()
            }
        }
    }
    
    // MARK: - Camera View
    private var cameraView: some View {
        ZStack {
            // AR camera background
            ARCameraView(session: faceTrackingVM.session)
                .ignoresSafeArea()
                .onAppear { 
                    // Only start if not showing onboarding
                    if !showOnboarding {
                        faceTrackingVM.start()
                    } else {
                        isReadyToStart = true
                    }
                }
                .onDisappear { faceTrackingVM.pause() }
            
            // MARK: center overlay, Guide Image
            if settings.showGuideImage, let action = faceTrackingVM.currentAction, !faceTrackingVM.isRoutineComplete, !faceTrackingVM.isTransitioning {
                GeometryReader { geometry in
                    // Calculate size based on the shorter side of the screen (maintains consistent size on rotation)
                    let minDimension = min(geometry.size.width, geometry.size.height)
                    let baseSize = minDimension / 2.5
                    let imageSize = baseSize * settings.guideImageScale
                    
                    // Determine image name (based on white image usage)
                    let imageSuffix = settings.useWhiteImage ? "_white" : ""
                    let normalImageName = "\(action.currentImageName)\(imageSuffix)"
                    let highlightImageName = "\(action.currentImageName)_green"
                    
                    ZStack {
                        // Normal image (white or default)
                        Image(normalImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                            .scaleEffect(faceTrackingVM.isHolding ? 1.1 : 1.0)
                            .opacity(faceTrackingVM.isHolding ? 0 : 0.7)
                        
                        // Green image (on success)
                        Image(highlightImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                            .scaleEffect(faceTrackingVM.isHolding ? 1.1 : 1.0)
                            .opacity(faceTrackingVM.isHolding ? 0.7 : 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: faceTrackingVM.isHolding)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: settings.guideImageScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: settings.useWhiteImage)
                    .transition(.scale.combined(with: .opacity))
                    .id("\(action.id)-\(action.currentSubStepIndex)-\(settings.useWhiteImage)")
                }
            }
            
            if faceTrackingVM.isRoutineComplete {
                CompletionCard(onRestart: {
                    faceTrackingVM.restartRoutine()
                })
                .padding(20)
            }
            
            //MARK: top information bar
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    if let action = faceTrackingVM.currentAction {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(action.name)
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                
                                Text("\(action.actionDescription)")
                                    .font(.headline)
                                
                                Text("tip: \(action.recognitionTip)")
                                    .foregroundStyle(.gray)
                                    .italic()
                                
                            }
                        }
                        .padding(20)
                    }
                    
                    Spacer()
                    
                    CircularStepProgressView(
                        currentStep: faceTrackingVM.isRoutineComplete
                        ? faceTrackingVM.routine.count
                        : faceTrackingVM.currentActionIndex + 1,
                        totalSteps: faceTrackingVM.routine.count,
                        currentAction: faceTrackingVM.currentAction
                    )
                    .padding(.trailing, 10)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // instant message capsule
                ZStack(alignment: .bottom){
                    VStack(spacing: 8) {
                        if let message = instructionMessage {
                            InstructionMessageCapsule(message: message.text, type: .instruction)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .id(message.id)
                        }
                        
                        if let message = holdingMessage {
                            InstructionMessageCapsule(message: message.text, type: .holding)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .id(message.id)
                        }
                        
                        if faceTrackingVM.isTransitioning {
                            InstructionMessageCapsule(message: "Complete! Moving to next exercise." , type: .transition)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: instructionMessage)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: holdingMessage)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: faceTrackingVM.isTransitioning)
                    .padding(.horizontal, 20)
                    
                    // Bottom buttons
                    HStack {
                        // Settings button - left
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white)
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 45)
                                        .fill(Color.gray)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        
                        Spacer()
                        
                        // Skip button - right
                        Button(action: {
                            withAnimation(.easeInOut) { faceTrackingVM.skipCurrentAction() }
                        }){
                            Text("Skip")
                                .fontWeight(.semibold)
                                .padding(.vertical, 20)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 45)
                                        .fill(Color.accentColor)
                                )
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .onChange(of: faceTrackingVM.currentAction?.currentInstruction) { newValue in
                if let instruction = newValue {
                    showInstructionMessage(instruction)
                }
            }
            .onChange(of: faceTrackingVM.isHolding) { newValue in
                if newValue {
                    showHoldingMessage()
                    
                } else {
                    hideHoldingMessage()
                }
            }
            .onChange(of: faceTrackingVM.isTransitioning) { newValue in
                if newValue {
                    // Hide existing messages when transition starts
                    hideAllMessages()
                }
            }
            .onAppear {
                // Show initial instruction message when app starts
                if let firstInstruction = faceTrackingVM.currentAction?.currentInstruction {
                    showInstructionMessage(firstInstruction)
                }
            }
        }
    }
    
    private var unsupportedScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "faceid")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text("Face Tracking Not Supported")
                .font(.title2.bold())
            Text(faceTrackingVM.statusMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Permission Request View
    private var permissionRequestView: some View {
        VStack(spacing: 30) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 12) {
                Text("Camera Access Required")
                    .font(.title.bold())
                
                Text("This app uses face tracking to guide you through facial exercises. Please grant camera access to continue.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                Task {
                    await faceTrackingVM.requestCameraPermission()
                    
                    // If permission granted, check if we should show onboarding first
                    if faceTrackingVM.cameraAuthorizationStatus == .authorized {
                        checkFirstLaunch()
                    }
                }
            }) {
                Text("Allow Camera Access")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }
    
    // MARK: - Permission Denied View
    private var permissionDeniedView: some View {
        VStack(spacing: 30) {
            Image(systemName: "camera.fill.badge.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            VStack(spacing: 12) {
                Text("Camera Access Denied")
                    .font(.title.bold())
                
                Text("Please enable camera access in Settings to use this app.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                // Open app settings
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }) {
                Text("Open Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }
    
    private func showInstructionMessage(_ text: String) {
        let newMessage = InstructionMessage(text: text)
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            instructionMessage = newMessage
        }
    }
    
    private func showHoldingMessage() {
        let newMessage = InstructionMessage(text: "Face Matched!")
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            // Hide instruction message
            instructionMessage = nil
            // Show holding message
            holdingMessage = newMessage
        }
    }
    
    private func hideHoldingMessage() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            holdingMessage = nil
        }
    }
    
    private func hideAllMessages() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            instructionMessage = nil
            holdingMessage = nil
        }
    }
    
    // MARK: - Onboarding Check
    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasLaunchedBefore)
        
        if !hasLaunchedBefore && faceTrackingVM.cameraAuthorizationStatus == .authorized {
            // First launch with camera permission: show onboarding
            isReadyToStart = true
            showOnboarding = true
        } else if hasLaunchedBefore && faceTrackingVM.cameraAuthorizationStatus == .authorized {
            // Not first launch and has permission: start immediately
            faceTrackingVM.start()
        }
    }
}

// MARK: - UserDefaults Keys
private enum UserDefaultsKeys {
    static let hasLaunchedBefore = "hasLaunchedBefore"
}

// MARK: - Design Preview
/// Static mockup of the execution (camera) screen for iterating on the design.
/// The real screen relies on ARKit + FaceTrackingViewModel, which can't run in the
/// canvas, so this reproduces the same layout over a simulated camera background.
private struct MainViewDesignPreview: View {
    // Sample data mimicking a live session
    private let sampleAction = FaceAction(
        id: "sample",
        name: "Cheek Lift",
        instruction: "Smile as wide as you can",
        imageName: "",
        requiredAnchors: [],
        detectionMode: .all,
        repeatGoal: 5,
        completedCount: 2,
        actionDescription: "Lift both cheeks toward your eyes",
        recognitionTip: "Keep your face centered in the frame"
    )

    var body: some View {
        ZStack {
            // Simulated camera background
            LinearGradient(
                colors: [Color(white: 0.25), Color(white: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Guide image placeholder (center overlay)
            Image(systemName: "face.smiling")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .foregroundStyle(.white.opacity(0.7))

            VStack(alignment: .center, spacing: 0) {
                // Top information bar
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(sampleAction.name)
                            .font(.largeTitle)
                            .fontWeight(.heavy)

                        Text(sampleAction.actionDescription)
                            .font(.headline)

                        Text("tip: \(sampleAction.recognitionTip)")
                            .foregroundStyle(.gray)
                            .italic()
                    }
                    .padding(20)

                    Spacer()

                    CircularStepProgressView(
                        currentStep: 3,
                        totalSteps: 10,
                        currentAction: sampleAction
                    )
                    .padding(.trailing, 10)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                // Instruction capsule + bottom buttons
                ZStack(alignment: .bottom) {
                    InstructionMessageCapsule(message: sampleAction.currentInstruction, type: .instruction)
                        .padding(.horizontal, 20)

                    HStack {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 45)
                                    .fill(Color.gray)
                            )

                        Spacer()

                        Text("Skip")
                            .fontWeight(.semibold)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 45)
                                    .fill(Color.accentColor)
                            )
                            .foregroundStyle(.white)
                    }
                }
                .padding(20)
            }
        }
    }
}

#Preview("Main Screen Design") {
    MainViewDesignPreview()
}


