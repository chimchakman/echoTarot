import SwiftUI

struct KeywordChipView: View {
    let keyword: String
    let isEditing: Bool
    let isUserAdded: Bool
    let onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            Text(keyword)
                .font(.subheadline)

            if isEditing, let onDelete {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.subheadline)
                }
                .accessibilityLabel("Delete \(keyword)")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isUserAdded ? Color.indigo.opacity(0.2) : Color.gray.opacity(0.15))
        .cornerRadius(16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isEditing ? "\(keyword), deletable" : keyword)
    }
}
