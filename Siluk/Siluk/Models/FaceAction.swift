import SwiftUI
import ARKit
import SceneKit

enum DetectionMode {
    case all
    case any
}

/// Sub-step structure for actions with multiple stages
struct ActionSubStep {
    let imageName: String
    let instruction: String
    let requiredAnchors: [ARFaceAnchor.BlendShapeLocation]  // Anchors that must be active
    let detectionMode: DetectionMode
    let excludedAnchors: [ARFaceAnchor.BlendShapeLocation]  // Anchors that must be inactive (e.g., winking)
    
    init(
        imageName: String,
        instruction: String,
        requiredAnchors: [ARFaceAnchor.BlendShapeLocation],
        detectionMode: DetectionMode,
        excludedAnchors: [ARFaceAnchor.BlendShapeLocation] = []
    ) {
        self.imageName = imageName
        self.instruction = instruction
        self.requiredAnchors = requiredAnchors
        self.detectionMode = detectionMode
        self.excludedAnchors = excludedAnchors
    }
}

struct FaceAction: Identifiable, Equatable {
    let id: String
    let name: String
    let instruction: String
    let imageName: String  // 기본 이미지 이름 (서브스텝이 없는 경우)
    let requiredAnchors: [ARFaceAnchor.BlendShapeLocation]
    let detectionMode: DetectionMode
    let repeatGoal: Int
    var completedCount: Int = 0
    
    // Action description properties
    let actionDescription: String  // Describes what this action does
    let recognitionTip: String      // Tips for better recognition
    
    // Properties for actions with sub-steps (optional)
    let subSteps: [ActionSubStep]?
    var currentSubStepIndex: Int = 0
    
    // Initializer with default values
    init(
        id: String,
        name: String,
        instruction: String,
        imageName: String,
        requiredAnchors: [ARFaceAnchor.BlendShapeLocation],
        detectionMode: DetectionMode,
        repeatGoal: Int,
        completedCount: Int = 0,
        actionDescription: String,
        recognitionTip: String,
        subSteps: [ActionSubStep]? = nil,
        currentSubStepIndex: Int = 0
    ) {
        self.id = id
        self.name = name
        self.instruction = instruction
        self.imageName = imageName
        self.requiredAnchors = requiredAnchors
        self.detectionMode = detectionMode
        self.repeatGoal = repeatGoal
        self.completedCount = completedCount
        self.actionDescription = actionDescription
        self.recognitionTip = recognitionTip
        self.subSteps = subSteps
        self.currentSubStepIndex = currentSubStepIndex
    }
    
    var isComplete: Bool { completedCount >= repeatGoal }
    
    // Get current sub-step
    var currentSubStep: ActionSubStep? {
        guard let subSteps = subSteps,
              currentSubStepIndex < subSteps.count else { return nil }
        return subSteps[currentSubStepIndex]
    }
    
    // Current image name to use
    var currentImageName: String {
        return currentSubStep?.imageName ?? imageName
    }
    
    // Current instruction to use
    var currentInstruction: String {
        return currentSubStep?.instruction ?? instruction
    }
    
    // Current anchors to check
    var currentAnchors: [ARFaceAnchor.BlendShapeLocation] {
        return currentSubStep?.requiredAnchors ?? requiredAnchors
    }
    
    // Current detection mode to use
    var currentDetectionMode: DetectionMode {
        return currentSubStep?.detectionMode ?? detectionMode
    }
    
    // Current anchors that must be inactive (e.g., for winking)
    var currentExcludedAnchors: [ARFaceAnchor.BlendShapeLocation] {
        return currentSubStep?.excludedAnchors ?? []
    }

    static func == (lhs: FaceAction, rhs: FaceAction) -> Bool {
        lhs.id == rhs.id && 
        lhs.completedCount == rhs.completedCount &&
        lhs.currentSubStepIndex == rhs.currentSubStepIndex
    }
}
