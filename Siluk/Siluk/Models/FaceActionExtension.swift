import SwiftUI
import ARKit
import SceneKit

extension FaceAction {
    static let defaultRoutine: [FaceAction] = [
        FaceAction(
            id: "eyeWink",
            name: "눈 윙크하기",
            instruction: "왼쪽 눈부터 시작하세요",
            imageName: "eyeWink_left",
            requiredAnchors: [.eyeBlinkLeft],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "양쪽 눈을 번갈아 윙크하여 눈 주변 근육을 이완시킵니다",
            recognitionTip: "한쪽 눈은 완전히 감고 다른 쪽 눈은 크게 뜨세요",
            subSteps: [
                ActionSubStep(
                    imageName: "eyeWink_left",
                    instruction: "왼쪽 눈을 감으세요",
                    requiredAnchors: [.eyeBlinkRight],
                    detectionMode: .all,
                    excludedAnchors: [.eyeBlinkLeft]
                ),
                ActionSubStep(
                    imageName: "eyeWink_right",
                    instruction: "오른쪽 눈을 감으세요",
                    requiredAnchors: [.eyeBlinkLeft],
                    detectionMode: .all,
                    excludedAnchors: [.eyeBlinkRight]
                )
            ]
        ),
        FaceAction(
            id: "mouthSide",
            name: "입 좌우로 움직이기",
            instruction: "입을 왼쪽으로 움직이세요",
            imageName: "mouthMove_left",
            requiredAnchors: [.mouthLeft],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "입을 좌우로 움직여 턱과 입 근육을 이완시킵니다",
            recognitionTip: "입을 한쪽으로 최대한 밀어주세요",
            subSteps: [
                ActionSubStep(
                    imageName: "mouthMove_right",
                    instruction: "입을 오른쪽으로 움직이세요",
                    requiredAnchors: [.mouthLeft],
                    detectionMode: .all
                ),
                ActionSubStep(
                    imageName: "mouthMove_left",
                    instruction: "입을 왼쪽으로 움직이세요",
                    requiredAnchors: [.mouthRight],
                    detectionMode: .all
                )
            ]
        ),
        FaceAction(
            id: "jawOpen",
            name: "입 크게 벌리기",
            instruction: "입을 최대한 크게 벌리세요",
            imageName: "jawOpen",
            requiredAnchors: [.jawOpen],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "입을 크게 벌려 턱관절과 얼굴 근육을 스트레칭합니다",
            recognitionTip: "입을 가능한 한 크게 벌리세요"
        ),
        FaceAction(
            id: "eyeWide",
            name: "눈 크게 뜨기",
            instruction: "눈을 최대한 크게 뜨세요",
            imageName: "eyeWide",
            requiredAnchors: [.eyeWideLeft, .eyeWideRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "눈을 크게 떠서 눈 주변과 이마 근육을 활성화합니다",
            recognitionTip: "눈을 가능한 한 크게 뜨세요"
        ),
        FaceAction(
            id: "cheekPuff",
            name: "볼 부풀리기",
            instruction: "양쪽 볼을 부풀리세요",
            imageName: "cheekPuff",
            requiredAnchors: [.cheekPuff],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "볼을 부풀려 볼과 입 근육을 사용합니다",
            recognitionTip: "입을 다물고 양쪽 볼에 공기를 가득 채우세요"
        ),
        FaceAction(
            id: "tongueOut",
            name: "혀 내밀기",
            instruction: "혀를 최대한 길게 내미세요",
            imageName: "tongueOut",
            requiredAnchors: [.tongueOut],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "혀를 내밀어 혀와 턱 아래 근육을 스트레칭합니다",
            recognitionTip: "혀를 가능한 한 길게 내미세요"
        ),
        FaceAction(
            id: "smile",
            name: "활짝 웃기",
            instruction: "크게 미소 지으세요",
            imageName: "smile",
            requiredAnchors: [.mouthSmileLeft, .mouthSmileRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "활짝 웃어 볼 근육을 올리고 밝은 표정을 만듭니다",
            recognitionTip: "치아를 살짝 보이며 양쪽 입꼬리를 최대한 높이 올리세요"
        ),
        FaceAction(
            id: "mouthFrown",
            name: "입꼬리 내리기",
            instruction: "입꼬리를 아래로 내리세요",
            imageName: "mouthFrown",
            requiredAnchors: [.mouthFrownLeft, .mouthFrownRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "입꼬리를 내려 얼굴 아래쪽 근육을 사용합니다",
            recognitionTip: "입을 다문 채 양쪽 입꼬리를 아래로 당기세요"
        ),
        FaceAction(
            id: "mouthPucker",
            name: "입술 오므리기",
            instruction: "입술을 앞으로 내미세요",
            imageName: "mouthPucker",
            requiredAnchors: [.mouthPucker, .mouthFunnel],
            detectionMode: .any,
            repeatGoal: 5,
            actionDescription: "입술을 오므려 입술과 주변 근육을 강화합니다",
            recognitionTip: "입술을 모아 뽀뽀하듯 앞으로 내미세요"
        ),
        FaceAction(
            id: "eyeLookUp",
            name: "위 보기",
            instruction: "눈동자를 위로 굴리세요",
            imageName: "eyeLookUp",
            requiredAnchors: [.eyeLookUpLeft, .eyeLookUpRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "눈동자를 위로 굴려 눈 근육을 운동합니다",
            recognitionTip: "카메라를 보다가 눈동자만 위로 반복해서 움직이세요"
        ),
        FaceAction(
            id: "eyeLookDown",
            name: "아래 보기",
            instruction: "눈동자를 아래로 굴리세요",
            imageName: "eyeLookDown",
            requiredAnchors: [.eyeLookDownLeft, .eyeLookDownRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "눈동자를 아래로 굴려 눈 근육의 유연성을 높입니다",
            recognitionTip: "카메라를 보다가 눈동자만 아래로 반복해서 움직이세요"
        ),
        FaceAction(
            id: "browRaise",
            name: "눈썹 올리기",
            instruction: "눈썹을 위로 올리세요",
            imageName: "browRaise",
            requiredAnchors: [.browInnerUp, .browOuterUpLeft, .browOuterUpRight],
            detectionMode: .all,
            repeatGoal: 5,
            actionDescription: "눈썹을 올려 이마 근육을 사용하고 이완시킵니다",
            recognitionTip: "이마에 주름을 만든다는 느낌으로 눈썹을 최대한 높이 올리세요"
        ),
    ]
}
