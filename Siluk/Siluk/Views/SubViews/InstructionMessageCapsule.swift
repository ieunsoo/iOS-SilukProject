import SwiftUI
import Foundation

// MARK: - Supporting Types
struct InstructionMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
}

enum MessageCapsuleType {
    case instruction
    case holding
    case transition

    
    var backgroundColor: Color {
        switch self {
        case .instruction: return .white
        case .holding: return .green
        case .transition: return .blue
        }
    }
    
    var textColor: Color {
        switch self {
        case .instruction: return .black
        case .holding: return .white
        case .transition: return .white
        }
    }
}

struct InstructionMessageCapsule: View {
    let message: String
    let type: MessageCapsuleType
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(message)")
                .foregroundStyle(type.textColor)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 20)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .fill(type.backgroundColor)
                }
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6) // MARK: Hardcoded opacity, radius, offset
        }
        
    }
}

#Preview {
    InstructionMessageCapsule(message: "테스트 메시지입니다.", type: MessageCapsuleType.instruction)
}
