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
            title: "Guide Image",
            description: "When the image turns green, you're doing it correctly!\nHold it briefly and it counts!"
        ),
        OnboardingFeatureItem(
            imageName: "circularProgress",
            title: "Progress Circle",
            description: "Check your progress with the circular graph in the top right"
        ),
        OnboardingFeatureItem(
            systemIconName: "gear",
            iconSize: 60,
            title: "Settings Button",
            description: "Adjust sensitivity and display options with the bottom left settings button"
        )
    ]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            titleSection
            featuresListSection
            Spacer()
            startButton
        }
        .padding(LayoutConstants.horizontalPadding)
        .background(Color(.systemBackground))
    }
    
    // MARK: - View Components
    private var titleSection: some View {
        Text("Welcome to Go!Face")
            .font(.largeTitle)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, LayoutConstants.horizontalPadding)
            .padding(.vertical, LayoutConstants.verticalPadding)
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
            Text("Get Started")
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
