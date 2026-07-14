import SwiftUI
import ARKit
import SceneKit

extension FaceAction {
    static let defaultRoutine: [FaceAction] = [
        FaceAction(
            id: "eyeWink",
            name: "Wink Your Eyes",
            instruction: "Start with your left eye",
            imageName: "eyeWink_left",
            requiredAnchors: [.eyeBlinkLeft],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "Alternate winking each eye to relax the muscles around your eyes",
            recognitionTip: "Close one eye completely while keeping the other wide open",
            subSteps: [
                ActionSubStep(
                    imageName: "eyeWink_left",
                    instruction: "Close your left eye",
                    requiredAnchors: [.eyeBlinkRight],
                    detectionMode: .all,
                    excludedAnchors: [.eyeBlinkLeft]
                ),
                ActionSubStep(
                    imageName: "eyeWink_right",
                    instruction: "Close your right eye",
                    requiredAnchors: [.eyeBlinkLeft],
                    detectionMode: .all,
                    excludedAnchors: [.eyeBlinkRight]
                )
            ]
        ),
        FaceAction(
            id: "mouthSide",
            name: "Move Your Mouth Sideways",
            instruction: "Move your mouth to the left",
            imageName: "mouthMove_left",
            requiredAnchors: [.mouthLeft],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "Move your mouth side to side to relax your jaw and mouth muscles",
            recognitionTip: "Push your mouth to one side as far as possible",
            subSteps: [
                ActionSubStep(
                    imageName: "mouthMove_right",
                    instruction: "Move your mouth to the right",
                    requiredAnchors: [.mouthLeft],
                    detectionMode: .all
                ),
                ActionSubStep(
                    imageName: "mouthMove_left",
                    instruction: "Move your mouth to the left",
                    requiredAnchors: [.mouthRight],
                    detectionMode: .all
                )
            ]
        ),
        FaceAction(
            id: "jawOpen",
            name: "Open Your Mouth Wide",
            instruction: "Open your mouth as wide as you can",
            imageName: "jawOpen",
            requiredAnchors: [.jawOpen],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "Open your mouth wide to stretch your jaw joint and facial muscles",
            recognitionTip: "Open your mouth as wide as possible"
        ),
        FaceAction(
            id: "eyeWide",
            name: "Widen Your Eyes",
            instruction: "Open your eyes as wide as you can",
            imageName: "eyeWide",
            requiredAnchors: [.eyeWideLeft, .eyeWideRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "Open your eyes wide to activate the muscles around your eyes and forehead",
            recognitionTip: "Open your eyes as wide as possible"
        ),
        FaceAction(
            id: "cheekPuff",
            name: "Puff Your Cheeks",
            instruction: "Puff both of your cheeks",
            imageName: "cheekPuff",
            requiredAnchors: [.cheekPuff],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "Puff your cheeks to engage your cheek and mouth muscles",
            recognitionTip: "Close your mouth and fill both cheeks with air"
        ),
        FaceAction(
            id: "tongueOut",
            name: "Stick Out Your Tongue",
            instruction: "Stick your tongue out as far as you can",
            imageName: "tongueOut",
            requiredAnchors: [.tongueOut],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "Stick out your tongue to stretch your tongue and under-chin muscles",
            recognitionTip: "Extend your tongue as far as possible"
        ),
        FaceAction(
            id: "smile",
            name: "Smile Wide",
            instruction: "Give a big smile",
            imageName: "smile",
            requiredAnchors: [.mouthSmileLeft, .mouthSmileRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "Smile wide to lift your cheek muscles and create a positive expression",
            recognitionTip: "Show your teeth slightly and raise both corners of your mouth as high as possible"
        ),
        FaceAction(
            id: "mouthFrown",
            name: "Frown Your Mouth",
            instruction: "Pull down the corners of your mouth",
            imageName: "mouthFrown",
            requiredAnchors: [.mouthFrownLeft, .mouthFrownRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "Pull down the corners of your mouth to engage your lower facial muscles",
            recognitionTip: "Keep your mouth closed and pull both corners downward"
        ),
        FaceAction(
            id: "mouthPucker",
            name: "Pucker Your Lips",
            instruction: "Push your lips forward",
            imageName: "mouthPucker",
            requiredAnchors: [.mouthPucker, .mouthFunnel],
            detectionMode: .any,
            repeatGoal: 5,
            actionDescription: "Pucker your lips to strengthen your lip and surrounding muscles",
            recognitionTip: "Gather your lips together and push them forward as if kissing"
        ),
        FaceAction(
            id: "eyeLookUp",
            name: "Look Up",
            instruction: "Roll your eyes upward",
            imageName: "eyeLookUp",
            requiredAnchors: [.eyeLookUpLeft, .eyeLookUpRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "Roll your eyes upward to exercise your eye muscles",
            recognitionTip: "Look at the camera, then move only your eyes upward repeatedly"
        ),
        FaceAction(
            id: "eyeLookDown",
            name: "Look Down",
            instruction: "Roll your eyes downward",
            imageName: "eyeLookDown",
            requiredAnchors: [.eyeLookDownLeft, .eyeLookDownRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "Roll your eyes downward to improve your eye muscle flexibility",
            recognitionTip: "Look at the camera, then move only your eyes downward repeatedly"
        ),
        FaceAction(
            id: "browRaise",
            name: "Raise Your Eyebrows",
            instruction: "Raise your eyebrows upward",
            imageName: "browRaise",
            requiredAnchors: [.browInnerUp, .browOuterUpLeft, .browOuterUpRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "Raise your eyebrows to engage and relax your forehead muscles",
            recognitionTip: "Imagine creating wrinkles on your forehead and raise your eyebrows as high as possible"
        ),
    ]
}
