import SwiftUI
import ARKit
import SceneKit

enum FaceSessionEvent {
    case faceUpdated([ARFaceAnchor.BlendShapeLocation: NSNumber])
    case error(String)
    case interrupted
    case interruptionEnded
}

final class FaceSessionDelegate: NSObject, ARSessionDelegate, @unchecked Sendable {
    var onEvent: (@MainActor @Sendable (FaceSessionEvent) -> Void)?

    private func send(_ event: FaceSessionEvent) {
        let callback = onEvent
        Task { @MainActor in callback?(event) }
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let face = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
        send(.faceUpdated(face.blendShapes))
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        send(.error(error.localizedDescription))
    }

    func sessionWasInterrupted(_ session: ARSession) {
        send(.interrupted)
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        send(.interruptionEnded)
    }
}
