import SwiftUI

struct SettingsView: View {
    @Bindable var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("가이드 이미지 표시하기", isOn: $settings.showGuideImage)
                    
                    if settings.showGuideImage {
                        
                        Toggle("가이드 이미지 색 반전", isOn: $settings.useWhiteImage)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("이미지 배율")
                                Spacer()
                                Text("\(Int(settings.guideImageScale * 100))%")
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                            
                            Slider(value: $settings.guideImageScale, in: 0.5...2.0, step: 0.1) {
                                Text("Image Size")
                            } minimumValueLabel: {
                                Image(systemName: "photo")
                                    .font(.caption)
                            } maximumValueLabel: {
                                Image(systemName: "photo")
                                    .font(.title3)
                            }
                            
                            HStack {
                                Spacer()
                                Button("초기화") {
                                    withAnimation {
                                        settings.guideImageScale = 1.0
                                    }
                                }
                                .font(.caption)
                                .buttonStyle(.borderless)
                                Spacer()
                            }
                        }
                        .animation(.easeInOut, value: settings.guideImageScale)
                    }
                    
                } header: {
                    Text("화면 출력")
                }
                
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("얼굴 인식 민감도")
                            Spacer()
                            Text(sensitivityLabel(for: settings.faceDetectionSensitivity))
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $settings.faceDetectionSensitivity, in: 0.0...1.0, step: 0.1) {
                            Text("Face Detection Sensitivity")
                        } minimumValueLabel: {
                            Text("둔감")
                                .font(.caption)
                        } maximumValueLabel: {
                            Text("민감")
                                .font(.caption)
                        }
                        
                        HStack {
                            Spacer()
                            Button("초기화") {
                                withAnimation {
                                    settings.faceDetectionSensitivity = 0.5
                                }
                            }
                            .font(.caption)
                            .buttonStyle(.borderless)
                            Spacer()
                        }
                    }
                    .animation(.easeInOut, value: settings.faceDetectionSensitivity)
                } header: {
                    Text("얼굴인식")
                } footer: {
                    Text("민감도가 높을수록 작은 얼굴 변화에도 쉽게 동작을 인식합니다.")
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sensitivityLabel(for value: Double) -> String {
        switch value {
        case 0.0...0.2:
            return "매우 낮음"
        case 0.2...0.4:
            return "낮음"
        case 0.4...0.6:
            return "보통"
        case 0.6...0.8:
            return "높음"
        case 0.8...1.0:
            return "매우높음"
        default:
            return "보통"
        }
    }
}

#Preview {
    SettingsView()
}
