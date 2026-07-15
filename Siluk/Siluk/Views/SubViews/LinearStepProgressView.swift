//
//  LinearStepProgressView.swift
//  Siluk
//
//  Created by eunsoo on 7/14/26.
//

import SwiftUI

/// A horizontal, elongated linear progress bar that mirrors CircularStepProgressView's
/// data and state (overall routine progress, per-action repeat counter, and sub-steps),
/// using green as the point color.
struct LinearStepProgressView: View {
    let currentStep: Int
    let totalSteps: Int
    let currentAction: FaceAction?
    var onSettingsTap: () -> Void = {}

    private var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStep) / Double(totalSteps)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            
            
            // Linear progress bar with the step counter on its right
            HStack(spacing: 12) {
                Button(action: onSettingsTap, label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.white)
                })

                VStack{
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Track
                            Capsule()
                                .fill(.gray.opacity(0.2))

                            // Fill
                            Capsule()
                                .fill(Color.green)
                                .frame(width: max(0, geometry.size.width * progress ))
                                .animation(.easeInOut(duration: 0.3), value: progress)
                        }
                    }
                    .frame(height: 16)
                    
                    
                }

                // Step counter wrapped in a light green capsule
                Text("\(currentStep) / \(totalSteps)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.green)
                    .monospacedDigit()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.2))
                    )
            }
            // Per-action indicators (repeat counter + sub-steps)
            if let action = currentAction {
                HStack(spacing: 12) {
//                    Spacer()

                    // Repeat counter bars
                    HStack(spacing: 6) {
                        ForEach(0..<action.repeatGoal, id: \.self) { index in
                            Capsule()
                                .fill(index < action.completedCount ? Color.green : Color.white.opacity(0.3))
                                .frame(width: 30, height: 4)
                                .animation(
                                    .spring(response: 0.3, dampingFraction: 0.5),
                                    value: action.completedCount
                                )
                        }
                    }
                    
//                    Spacer()÷

                    // Sub-step indicators
                    
                    
                }
            }
            
        }
    }
}

#Preview("With Action") {
    LinearStepProgressView(
        currentStep: 3,
        totalSteps: 10,
        currentAction: FaceAction.defaultRoutine.first
    )
    .padding()
    .background(Color.black)
}

#Preview("No Action") {
    LinearStepProgressView(
        currentStep: 3,
        totalSteps: 10,
        currentAction: nil
    )
    .padding()
    .background(Color.black)
}
