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
            Text("Stretching Complete!")
                .font(.system(size: 28, weight: .bold))
            
            // Encouragement message
            VStack(spacing: 6) {
                Text("Good work! Your facial muscles are more relaxed.")
                    .font(.body.weight(.medium))
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, 10)
            
            // Progress message
            VStack(spacing: 4) {
                Text("When muscles that weren't used before start to move,")
                Text("you'll find a natural smile coming more easily.")
            }
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            
            Button(action: onRestart) {
                Label("Restart", systemImage: "arrow.counterclockwise")
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
