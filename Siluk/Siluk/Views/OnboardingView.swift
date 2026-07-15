import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @Binding var isPresented: Bool
    
    // MARK: - Constants
    private enum LayoutConstants {
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 30
        static let buttonVerticalPadding: CGFloat = 16
    }
    
    // MARK: - Feature Items Data
    private let features: [OnboardingFeatureItem] = [
        OnboardingFeatureItem(
            imageName: "smile_green",
            title: "가이드 이미지",
            description: "이미지가 초록색으로 바뀌면 올바르게 하고 있는 거예요!\n잠시 유지하면 횟수가 올라갑니다!"
        ),
        OnboardingFeatureItem(
            systemIconName: "gear",
            iconSize: 60,
            title: "설정 버튼",
            description: "왼쪽 상단 설정 버튼으로 민감도와 화면 옵션을 조절하세요"
        ),
        OnboardingFeatureItem(
            systemIconName: "lock.iphone",
            iconSize: 60,
            title: "개인정보 보호",
            description: "실룩은 인터넷 연결이 필요 없는 앱 입니다. 카메라는 얼굴 인식을 위해서만 존재할 뿐 따로 저장되지 않습니다!"
        )
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            titleSection
            subTitleSection
            featuresListSection
            Spacer()
            startButton
        }
        .padding(LayoutConstants.horizontalPadding)
        .background(Color(.systemBackground))
    }
    
    // MARK: - View Components
    private var titleSection: some View {
        Text("실룩에 오신 것을 환영합니다.")
            .font(.title)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, LayoutConstants.horizontalPadding)
//            .padding(.vertical, LayoutConstants.verticalPadding)
    }
    private var subTitleSection: some View {
        Text("열심히 얼굴을 실룩여봐요!")
            .font(.title3)
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, LayoutConstants.verticalPadding)
    }
    
    private var featuresListSection: some View {
        VStack(spacing: 0) {
            ForEach(features.indices, id: \.self) { index in
                FeatureRow(feature: features[index])
            }
        }
    }
    
    private var startButton: some View {
        Button {
            // Mark onboarding as completed
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            isPresented = false
        } label: {
            Text("시작하기")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LayoutConstants.buttonVerticalPadding)
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
        .padding(LayoutConstants.horizontalPadding)
    }
}

// MARK: - Onboarding Feature Item Model
struct OnboardingFeatureItem {
    let imageName: String?
    let systemIconName: String?
    let iconSize: CGFloat
    let title: String
    let description: String
    
    init(
        imageName: String? = nil,
        systemIconName: String? = nil,
        iconSize: CGFloat = 70,
        title: String,
        description: String
    ) {
        self.imageName = imageName
        self.systemIconName = systemIconName
        self.iconSize = iconSize
        self.title = title
        self.description = description
    }
}

// MARK: - Feature Row Component
private struct FeatureRow: View {
    let feature: OnboardingFeatureItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            featureIcon
            featureTextContent
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
    }
    
    @ViewBuilder
    private var featureIcon: some View {
        if let imageName = feature.imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: feature.iconSize, height: feature.iconSize)
        } else if let systemIconName = feature.systemIconName {
            Image(systemName: systemIconName)
                .resizable()
                .scaledToFit()
                .frame(width: feature.iconSize, height: feature.iconSize)
                .foregroundStyle(.secondary.opacity(0.8))
        }
    }
    
    private var featureTextContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(feature.title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(feature.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview{
    OnboardingView(isPresented: .constant(true))
}
