import SwiftUI
import ARKit
import SceneKit

struct MainView: View {
    @StateObject private var faceTrackingVM = FaceTrackingViewModel()
    @State private var showSettings = false
    @State private var showOnboarding = false
    @State private var isReadyToStart = false
    @Bindable private var settings = AppSettings.shared

    // Diameter of the Face ID style cutout as a fraction of the shorter screen side.
    // Shared by the cutout overlay and the instruction text placed below it.
    private let cutoutFraction: CGFloat = 0.7
    
    var body: some View {
        ZStack {
            if faceTrackingVM.isSupported {
                // Check camera authorization status
                switch faceTrackingVM.cameraAuthorizationStatus {
                case .authorized:
                    cameraView
                case .notDetermined:
                    permissionRequestView
                case .denied, .restricted:
                    permissionDeniedView
                @unknown default:
                    permissionRequestView
                }
            } else {
                unsupportedScreen
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
                .presentationDetents([.large])
                .interactiveDismissDisabled()
        }
        .onAppear {
            checkFirstLaunch()
        }
        .onChange(of: showOnboarding) { isShowing in
            // When onboarding is dismissed and camera is authorized, start the session
            if !isShowing && faceTrackingVM.cameraAuthorizationStatus == .authorized && isReadyToStart {
                faceTrackingVM.start()
            }
        }
    }
    
    // MARK: - Camera View
    var cameraView: some View {
        ZStack {
            // AR camera background
            ARCameraView(session: faceTrackingVM.session)
                .ignoresSafeArea()
                .onAppear {
                    // Only start if not showing onboarding
                    if !showOnboarding {
                        faceTrackingVM.start()
                    } else {
                        isReadyToStart = true
                    }
                }
                .onDisappear { faceTrackingVM.pause() }

            // MARK: center overlay, Guide Image
            if settings.showGuideImage, let action = faceTrackingVM.currentAction, !faceTrackingVM.isRoutineComplete, !faceTrackingVM.isTransitioning {
                GeometryReader { geometry in
                    // Calculate size based on the shorter side of the screen (maintains consistent size on rotation)
                    let minDimension = min(geometry.size.width, geometry.size.height)
                    let baseSize = minDimension / 2.5
                    let imageSize = baseSize * settings.guideImageScale

                    // Determine image name (based on white image usage)
                    let imageSuffix = settings.useWhiteImage ? "_white" : ""
                    let normalImageName = "\(action.currentImageName)\(imageSuffix)"
                    let highlightImageName = "\(action.currentImageName)_green"

                    ZStack {
                        // Normal image (white or default)
                        Image(normalImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                            .scaleEffect(faceTrackingVM.isHolding ? 1.1 : 1.0)
                            .opacity(faceTrackingVM.isHolding ? 0 : 0.7)

                        // Green image (on success)
                        Image(highlightImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                            .scaleEffect(faceTrackingVM.isHolding ? 1.1 : 1.0)
                            .opacity(faceTrackingVM.isHolding ? 0.7 : 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: faceTrackingVM.isHolding)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: settings.guideImageScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: settings.useWhiteImage)
                    .transition(.scale.combined(with: .opacity))
                    .id("\(action.id)-\(action.currentSubStepIndex)-\(settings.useWhiteImage)")
                }
            }

            // Face ID style dark layer with a circular cutout in the center
            FaceCutoutOverlay(circleFraction: cutoutFraction)

            // Instruction text centered right below the cutout circle
            if !faceTrackingVM.isRoutineComplete, let action = faceTrackingVM.currentAction {
                GeometryReader { geometry in
                    let diameter = min(geometry.size.width, geometry.size.height) * cutoutFraction
                    Text(faceTrackingVM.isHolding ? "얼굴 인식 완료!" : action.currentInstruction)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(faceTrackingVM.isHolding ? Color.green : Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .frame(maxWidth: .infinity)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: faceTrackingVM.isHolding)
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 2 + diameter / 2 + 40
                        )
                }
                .allowsHitTesting(false)
            }

            if faceTrackingVM.isRoutineComplete {
                CompletionCard(onRestart: {
                    faceTrackingVM.restartRoutine()
                })
                .padding(20)
            }

            //MARK: top information + bottom buttons
            VStack(alignment: .leading, spacing: 0) {
                // Overall routine progress bar at the very top
                LinearStepProgressView(
                    currentStep: faceTrackingVM.currentActionIndex + 1,
                    totalSteps: faceTrackingVM.routine.count,
                    currentAction: faceTrackingVM.currentAction,
                    onSettingsTap: { showSettings = true }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // Top information text (drawn directly on the black layer)
                if let action = faceTrackingVM.currentAction {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(action.name)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(.white)

                        Text(action.actionDescription)
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text("팁: \(action.recognitionTip)")
                            .foregroundStyle(.gray)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }

                Spacer()

                // Bottom buttons
                HStack {
                    Spacer()

                    // Skip button - right
                    Button(action: {
                        withAnimation(.easeInOut) { faceTrackingVM.skipCurrentAction() }
                    }){
                        Text("건너뛰기")
                            .fontWeight(.semibold)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 45)
                                    .fill(Color.accentColor)
                            )
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
        }
    }
    
    private var unsupportedScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "faceid")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text("얼굴 인식을 지원하지 않는 기기입니다")
                .font(.title2.bold())
            Text(faceTrackingVM.statusMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Permission Request View
    private var permissionRequestView: some View {
        VStack(spacing: 30) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 12) {
                Text("카메라 접근 권한이 필요합니다")
                    .font(.title.bold())

                Text("이 앱은 얼굴 인식을 통해 얼굴 운동을 안내합니다. 계속하려면 카메라 접근을 허용해 주세요.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                Task {
                    await faceTrackingVM.requestCameraPermission()
                    
                    // If permission granted, check if we should show onboarding first
                    if faceTrackingVM.cameraAuthorizationStatus == .authorized {
                        checkFirstLaunch()
                    }
                }
            }) {
                Text("카메라 접근 허용")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }
    
    // MARK: - Permission Denied View
    private var permissionDeniedView: some View {
        VStack(spacing: 30) {
            Image(systemName: "camera.fill.badge.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            VStack(spacing: 12) {
                Text("카메라 접근이 거부되었습니다")
                    .font(.title.bold())

                Text("이 앱을 사용하려면 설정에서 카메라 접근을 허용해 주세요.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                // Open app settings
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }) {
                Text("설정 열기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding(40)
    }
    
    // MARK: - Onboarding Check
    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasLaunchedBefore)
        
        if !hasLaunchedBefore && faceTrackingVM.cameraAuthorizationStatus == .authorized {
            // First launch with camera permission: show onboarding
            isReadyToStart = true
            showOnboarding = true
        } else if hasLaunchedBefore && faceTrackingVM.cameraAuthorizationStatus == .authorized {
            // Not first launch and has permission: start immediately
            faceTrackingVM.start()
        }
    }
}

// MARK: - UserDefaults Keys
private enum UserDefaultsKeys {
    static let hasLaunchedBefore = "hasLaunchedBefore"
}

// MARK: - Face ID Style Cutout Overlay
/// A dark layer covering the whole screen with a circular hole punched in the
/// center, mimicking iOS Face ID enrollment. The camera behind shows through the hole.
struct FaceCutoutOverlay: View {
    /// Diameter of the circular hole as a fraction of the shorter screen side.
    var circleFraction: CGFloat = 1
    /// Fill color / opacity of the surrounding mask.
    var overlayColor: Color = .black.opacity(0.9)
    /// Ring drawn around the cutout edge.
    var ringColor: Color = .white.opacity(0.9)
    var ringWidth: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            let diameter = min(geometry.size.width, geometry.size.height) * circleFraction
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                // Dark mask with the circle cut out (even-odd rule punches the hole)
                overlayColor
                    .mask {
                        Rectangle()
                            .overlay {
                                Circle()
                                    .frame(width: diameter, height: diameter)
                                    .position(center)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                    }

                // Edge ring around the cutout
//                Circle()
//                    .stroke(ringColor, lineWidth: ringWidth)
//                    .frame(width: diameter, height: diameter)
//                    .position(center)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Preview
/// Renders the real camera screen. In the canvas the AR feed shows as a blank
/// background (ARKit needs a device), but the overlay design and live sample data
/// from FaceTrackingViewModel's default routine render exactly as in the app.
#Preview("Camera Screen") {
    MainView().cameraView
}


