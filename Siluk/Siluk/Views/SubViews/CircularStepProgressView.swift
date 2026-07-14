import SwiftUI
import ARKit
import SceneKit

struct CircularStepProgressView: View {
    let currentStep: Int
    let totalSteps: Int
    let currentAction: FaceAction?

    private var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStep) / Double(totalSteps)
    }

    var body: some View {
        ZStack {
            
            //inner circle
            Circle()
                .stroke(.gray.opacity(0.2), lineWidth: 10)

            //bar
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)

            //current step message
            VStack(spacing: 4) {
                Text("\(currentStep)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                if let action = currentAction {
                    VStack(spacing: 6) {
                        // all repeat counter
                        HStack(spacing: 6) {
                            ForEach(0..<action.repeatGoal, id: \.self) { index in
                                Circle()
                                    .fill(index < action.completedCount ? Color.green : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index < action.completedCount ? 1.0 : 0.8)
                                    .animation(
                                        .spring(response: 0.3, dampingFraction: 0.5),
                                        value: action.completedCount
                                    )
                            }
                        }
                        // subSteps
                        if let subSteps = action.subSteps, subSteps.count > 1 {
                            HStack(spacing: 4) {
                                ForEach(0..<subSteps.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == action.currentSubStepIndex ? Color.blue : Color.white.opacity(0.3))
                                        .frame(width: 6, height: 6)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.blue, lineWidth: index == action.currentSubStepIndex ? 1.5 : 0)
                                        )
                                }
                            }
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: action.currentSubStepIndex)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .frame(width: 130, height: 130)
        .padding(.vertical, 5)

    }
}


#Preview("No Action") {
    CircularStepProgressView(
        currentStep: 3,
        totalSteps: 10,
        currentAction: nil
    )
    .padding()
    .background(Color.gray.opacity(0.2))
}



