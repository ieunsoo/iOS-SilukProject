# 실룩 (Siluk)

ARKit 기반의 얼굴 스트레칭 가이드 앱입니다.

TrueDepth 카메라로 사용자의 표정을 실시간으로 추적하여, 정해진 루틴에 따라 얼굴 근육을 스트레칭하도록 안내합니다. 각 동작이 올바르게 수행되었는지 인식하고, 한 세트가 끝나면 자동으로 다음 동작으로 넘어갑니다.

표정 짓기가 어색하거나 표정 근육이 점점 굳어가는 걸 느끼는 사람들을 위해 시작한 개인 프로젝트이며, 원래는 Swift Student Challenge 제출용으로 만들었다가 이후 앱스토어 배포를 목표로 개인 사이드 프로젝트로 이어가고 있습니다.

## 동작 방식

앱은 총 12가지 얼굴 운동으로 구성된 루틴을 진행합니다. 각 운동은 특정 표정을 지었다가 풀어야 1회로 카운트되며, 5회를 채우면 자동으로 다음 운동으로 넘어갑니다.

카메라 화면 위에는 목표 동작을 보여주는 가이드 이미지가 겹쳐 표시됩니다. 사용자가 동작을 올바르게 수행하면 가이드 이미지가 초록색으로 바뀌고 살짝 커지면서 피드백을 줍니다. 화면 상단의 원형 진행바는 전체 단계 중 현재 몇 번째 단계인지를 보여줍니다.

일부 운동은 세부 단계(sub-step)로 나뉘어 있습니다. 예를 들어 윙크 운동은 왼쪽 눈과 오른쪽 눈을 번갈아 감아야 하고, 입 옆으로 움직이기 운동은 좌우를 번갈아 수행해야 합니다. 이런 운동은 필요한 blend shape 앵커와 함께 제외되어야 할 앵커까지 함께 확인해서 각 방향을 독립적으로 인식합니다.

### 운동 목록

| 운동 | 인식 방식 |
|---|---|
| 윙크 (좌우 번갈아) | eyeBlink + 반대쪽 눈 제외 조건 |
| 입 옆으로 움직이기 (좌우 번갈아) | mouthLeft / mouthRight |
| 입 크게 벌리기 | jawOpen |
| 눈 크게 뜨기 | eyeWideLeft + eyeWideRight |
| 볼 부풀리기 | cheekPuff |
| 혀 내밀기 | tongueOut |
| 미소 짓기 | mouthSmileLeft + mouthSmileRight |
| 입꼬리 내리기 | mouthFrownLeft + mouthFrownRight |
| 입술 오므리기 | mouthPucker / mouthFunnel |
| 눈 위로 굴리기 | eyeLookUpLeft + eyeLookUpRight |
| 눈 아래로 굴리기 | eyeLookDownLeft + eyeLookDownRight |
| 눈썹 올리기 | browInnerUp + browOuterUpLeft + browOuterUpRight |

## 아키텍처

얼굴 추적 로직과 UI 레이어를 분리한 MVVM 구조를 따릅니다.

`FaceTrackingViewModel`이 ARKit 세션을 소유하고, `FaceSessionDelegate`로부터 받은 blend shape 데이터를 처리하며, 루틴 진행 상태를 관리합니다. 인식은 엣지 트리거 방식으로 동작합니다 — 표정을 유지하는 동안이 아니라 **풀었을 때** 1회로 카운트되며, 이를 통해 의도치 않은 중복 카운트를 방지합니다.

`FaceAction`은 각 운동에 필요한 앵커, 인식 모드(all/any), 그리고 선택적인 세부 단계를 정의합니다. 세부 단계를 이용하면 하나의 운동이 반복마다 다른 앵커 조합을 순환하도록 만들 수 있습니다.

뷰 레이어는 전부 SwiftUI로 작성되었고, AR 카메라 화면은 `UIViewRepresentable`을 통해 `ARCameraView`로 연결됩니다.

## 기술 스택

SwiftUI, ARKit, SceneKit

## 요구 사항

TrueDepth 카메라가 탑재된 iPhone (iPhone X 이상)

> 현재 프로젝트의 배포 타깃은 iOS 26.0으로 설정되어 있습니다. 실제 앱스토어 배포 전 지원 기기 범위를 고려해 조정이 필요할 수 있습니다.

## 상태

개인 개발 중이며, 앱스토어 배포를 목표로 하고 있습니다.
