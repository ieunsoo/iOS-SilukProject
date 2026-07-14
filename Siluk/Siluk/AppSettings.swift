import SwiftUI
import Observation

// MARK: - AppSettings
@MainActor
@Observable
class AppSettings {
    static let shared = AppSettings()

    var showGuideImage: Bool {
        didSet { defaults.set(showGuideImage, forKey: "showGuideImage") }
    }
    var guideImageScale: Double {
        didSet { defaults.set(guideImageScale, forKey: "guideImageScale") }
    }
    var useWhiteImage: Bool {
        didSet { defaults.set(useWhiteImage, forKey: "useWhiteImage") }
    }
    var faceDetectionSensitivity: Double {
        didSet { defaults.set(faceDetectionSensitivity, forKey: "faceDetectionSensitivity") }
    }

    @ObservationIgnored private let defaults = UserDefaults.standard

    private init() {
        defaults.register(defaults: [
            "showGuideImage": true,
            "guideImageScale": 1.0,
            "useWhiteImage": false,
            "faceDetectionSensitivity": 0.5,
        ])

        showGuideImage = defaults.bool(forKey: "showGuideImage")
        guideImageScale = defaults.double(forKey: "guideImageScale")
        useWhiteImage = defaults.bool(forKey: "useWhiteImage")
        faceDetectionSensitivity = defaults.double(forKey: "faceDetectionSensitivity")
    }
}
