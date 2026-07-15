import SwiftUI

struct CompletionCard: View {
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            Text("🎉")
                .font(.system(size: 72))
                .padding(.bottom, 24)
            
            // Headline
            Text("스트레칭 완료!")
                .font(.system(size: 28, weight: .bold))

            // Encouragement message
            VStack(spacing: 6) {
                Text("수고하셨어요! 얼굴 근육이 한결 부드러워졌어요.")
                    .font(.body.weight(.medium))
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, 10)

            // Progress message
            VStack(spacing: 4) {
                Text("평소 쓰지 않던 근육이 움직이기 시작하면,")
                Text("자연스러운 미소가 더 쉽게 지어질 거예요.")
            }
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            
            Button(action: onRestart) {
                Label("다시 시작", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor)
                    )
            }
            .padding(.top, 20)
        }
        .padding(60)
        .frame(maxWidth: 500)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .padding(20) // Padding for smaller devices like iPhone to prevent the card from filling the entire screen
    }
}

#Preview {
    CompletionCard(onRestart: {})
}
