import Foundation

struct CardKeywordCustomization: Codable, Sendable {
    var addedUpright: [String] = []
    var removedUpright: [String] = []
    var addedReversed: [String] = []
    var removedReversed: [String] = []

    static let empty = CardKeywordCustomization()

    var isEmpty: Bool {
        addedUpright.isEmpty && removedUpright.isEmpty &&
        addedReversed.isEmpty && removedReversed.isEmpty
    }
}
