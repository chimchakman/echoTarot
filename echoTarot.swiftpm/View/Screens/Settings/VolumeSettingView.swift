import SwiftUI

struct VolumeSettingView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("음량", systemImage: "speaker.wave.2")
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(viewModel.speechVolume * 100))%")
                        .foregroundColor(.white.opacity(0.6))
                }

                Slider(value: Binding(
                    get: { Double(viewModel.speechVolume) },
                    set: { viewModel.updateSpeechVolume(Float($0)) }
                ), in: 0...1, step: 0.1)
                .tint(.indigo)
                .accessibilityLabel("음량")
                .accessibilityValue("\(Int(viewModel.speechVolume * 100))퍼센트")
            }
            .padding()
            .background(Color.white.opacity(0.25))
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("말하기 속도", systemImage: "hare")
                        .foregroundColor(.white)
                    Spacer()
                    Text(speedLabel)
                        .foregroundColor(.white.opacity(0.6))
                }

                Slider(value: Binding(
                    get: { Double(viewModel.speechRate) },
                    set: { viewModel.updateSpeechRate(Float($0)) }
                ), in: 0.3...0.7, step: 0.1)
                .tint(.indigo)
                .accessibilityLabel("말하기 속도")
                .accessibilityValue(speedLabel)
            }
            .padding()
            .background(Color.white.opacity(0.25))
            .cornerRadius(12)
        }
    }

    private var speedLabel: String {
        if viewModel.speechRate < 0.4 {
            return "느림"
        } else if viewModel.speechRate < 0.55 {
            return "보통"
        } else {
            return "빠름"
        }
    }
}
