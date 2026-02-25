import SwiftUI

struct SpreadSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: 12) {
            ForEach(TarotSpread.allCases, id: \.self) { spread in
                Button(action: {
                    viewModel.setDefaultSpread(spread)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: spread == .oneCard ? "1.circle.fill" : "3.circle.fill")
                                Text(spread.koreanName)
                                    .fontWeight(.medium)
                            }

                            Text(spread.description)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }

                        Spacer()

                        if viewModel.defaultSpread == spread {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.indigo)
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(viewModel.defaultSpread == spread ? Color.indigo.opacity(0.5) : Color.black.opacity(0.5))
                    .cornerRadius(12)
                }
                .accessibilityLabel("\(spread.koreanName): \(spread.description)")
                .accessibilityAddTraits(viewModel.defaultSpread == spread ? .isSelected : [])
            }
        }
    }
}
