import SwiftUI

struct AccessibleCard: View {
    let card: TarotCard
    let isReversed: Bool
    let position: String?
    let showMeaning: Bool
    let showImageDescriptionButton: Bool

    @ObservedObject private var settingsManager = SettingsManager.shared

    init(card: TarotCard, isReversed: Bool = false, position: String? = nil, showMeaning: Bool = true, showImageDescriptionButton: Bool = false) {
        self.card = card
        self.isReversed = isReversed
        self.position = position
        self.showMeaning = showMeaning
        self.showImageDescriptionButton = showImageDescriptionButton
    }

    var body: some View {
        VStack(spacing: 12) {
            if let position = position {
                Text(position)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }

            Image(card.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(isReversed ? .degrees(180) : .zero)
                .frame(maxHeight: 300)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(card.koreanName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                if isReversed {
                    Text("역방향")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }

                if showMeaning {
                    Text(settingsManager.effectiveMeaning(for: card, isReversed: isReversed))
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if showImageDescriptionButton {
                    CardImageDescriptionButton(card: card)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .accessibilityElement(children: showImageDescriptionButton ? .contain : .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        var description = card.koreanName
        if let position = position {
            description = "\(position), \(description)"
        }
        if isReversed {
            description += ", 역방향"
        }
        if showMeaning {
            description += ". \(settingsManager.effectiveMeaning(for: card, isReversed: isReversed))"
        }
        return description
    }
}
