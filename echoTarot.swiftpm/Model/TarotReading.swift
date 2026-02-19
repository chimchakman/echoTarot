import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
final class TarotReading {
    var id: UUID
    var date: Date
    var spreadType: String // "oneCard" or "threeCard"
    var questionAudioPath: String?
    var readingAudioPath: String?
    var cardIds: [String] // Array of card IDs drawn
    var cardReversals: [Bool] // Whether each card is reversed
    var hashtags: [String]
    var notes: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        spreadType: String,
        questionAudioPath: String? = nil,
        readingAudioPath: String? = nil,
        cardIds: [String] = [],
        cardReversals: [Bool] = [],
        hashtags: [String] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.spreadType = spreadType
        self.questionAudioPath = questionAudioPath
        self.readingAudioPath = readingAudioPath
        self.cardIds = cardIds
        self.cardReversals = cardReversals
        self.hashtags = hashtags
        self.notes = notes
    }
}
// Legacy model for iOS 16 and below
struct TarotReadingLegacy: Codable, Identifiable {
    var id: UUID
    var date: Date
    var spreadType: String
    var questionAudioPath: String?
    var readingAudioPath: String?
    var cardIds: [String]
    var cardReversals: [Bool]
    var hashtags: [String]
    var notes: String?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        spreadType: String,
        questionAudioPath: String? = nil,
        readingAudioPath: String? = nil,
        cardIds: [String] = [],
        cardReversals: [Bool] = [],
        hashtags: [String] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.spreadType = spreadType
        self.questionAudioPath = questionAudioPath
        self.readingAudioPath = readingAudioPath
        self.cardIds = cardIds
        self.cardReversals = cardReversals
        self.hashtags = hashtags
        self.notes = notes
    }
}

