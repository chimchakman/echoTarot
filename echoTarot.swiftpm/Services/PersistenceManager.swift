import Foundation
import SwiftData

@MainActor
final class PersistenceManager {
    static let shared = PersistenceManager()

    // iOS 17+ SwiftData
    private var _container: Any?
    
    @available(iOS 17.0, *)
    var container: ModelContainer? {
        if _container == nil {
            do {
                let schema = Schema([TarotReading.self])
                let config = ModelConfiguration(isStoredInMemoryOnly: false)
                _container = try ModelContainer(for: schema, configurations: config)
            } catch {
                print("Failed to create ModelContainer: \(error)")
                _container = NSNull()
            }
        }
        return _container as? ModelContainer
    }
    
    @available(iOS 17.0, *)
    private var context: ModelContext? {
        container?.mainContext
    }

    // Legacy UserDefaults storage for iOS 16
    private let legacyReadingsKey = "echoTarot.legacyReadings"
    
    private init() {}

    // MARK: - Save Reading
    
    func saveReading(
        id: UUID = UUID(),
        date: Date = Date(),
        spreadType: String,
        questionAudioPath: String? = nil,
        readingAudioPath: String? = nil,
        cardIds: [String] = [],
        cardReversals: [Bool] = [],
        hashtags: [String] = [],
        notes: String? = nil
    ) throws {
        if #available(iOS 17.0, *) {
            let reading = TarotReading(
                id: id,
                date: date,
                spreadType: spreadType,
                questionAudioPath: questionAudioPath,
                readingAudioPath: readingAudioPath,
                cardIds: cardIds,
                cardReversals: cardReversals,
                hashtags: hashtags,
                notes: notes
            )
            guard let context = context else {
                throw PersistenceError.contextUnavailable
            }
            context.insert(reading)
            try context.save()
        } else {
            let reading = TarotReadingLegacy(
                id: id,
                date: date,
                spreadType: spreadType,
                questionAudioPath: questionAudioPath,
                readingAudioPath: readingAudioPath,
                cardIds: cardIds,
                cardReversals: cardReversals,
                hashtags: hashtags,
                notes: notes
            )
            saveLegacyReading(reading)
        }
    }

    // MARK: - Fetch Readings
    
    func fetchAllReadings() throws -> [ReadingProtocol] {
        if #available(iOS 17.0, *) {
            guard let context = context else {
                throw PersistenceError.contextUnavailable
            }
            let descriptor = FetchDescriptor<TarotReading>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try context.fetch(descriptor).map { $0 as ReadingProtocol }
        } else {
            return fetchLegacyReadings().map { $0 as ReadingProtocol }
        }
    }

    func fetchReadings(for cardId: String) throws -> [ReadingProtocol] {
        if #available(iOS 17.0, *) {
            guard let context = context else {
                throw PersistenceError.contextUnavailable
            }
            let predicate = #Predicate<TarotReading> { reading in
                reading.cardIds.contains(cardId)
            }
            let descriptor = FetchDescriptor<TarotReading>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try context.fetch(descriptor).map { $0 as ReadingProtocol }
        } else {
            return fetchLegacyReadings()
                .filter { $0.cardIds.contains(cardId) }
                .map { $0 as ReadingProtocol }
        }
    }

    func fetchReadings(with hashtag: String) throws -> [ReadingProtocol] {
        if #available(iOS 17.0, *) {
            guard let context = context else {
                throw PersistenceError.contextUnavailable
            }
            let predicate = #Predicate<TarotReading> { reading in
                reading.hashtags.contains(hashtag)
            }
            let descriptor = FetchDescriptor<TarotReading>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return try context.fetch(descriptor).map { $0 as ReadingProtocol }
        } else {
            return fetchLegacyReadings()
                .filter { $0.hashtags.contains(hashtag) }
                .map { $0 as ReadingProtocol }
        }
    }

    // MARK: - Delete Reading
    
    func deleteReading(_ reading: any ReadingProtocol) throws {
        if #available(iOS 17.0, *) {
            guard let context = context else {
                throw PersistenceError.contextUnavailable
            }
            if let swiftDataReading = reading as? TarotReading {
                context.delete(swiftDataReading)
                try context.save()
            }
        } else {
            if let legacyReading = reading as? TarotReadingLegacy {
                deleteLegacyReading(legacyReading)
            }
        }
    }
    
    // MARK: - Legacy Storage (iOS 16)
    
    private func saveLegacyReading(_ reading: TarotReadingLegacy) {
        var readings = fetchLegacyReadings()
        readings.append(reading)
        if let encoded = try? JSONEncoder().encode(readings) {
            UserDefaults.standard.set(encoded, forKey: legacyReadingsKey)
        }
    }
    
    private func fetchLegacyReadings() -> [TarotReadingLegacy] {
        guard let data = UserDefaults.standard.data(forKey: legacyReadingsKey),
              let readings = try? JSONDecoder().decode([TarotReadingLegacy].self, from: data) else {
            return []
        }
        return readings.sorted { $0.date > $1.date }
    }
    
    private func deleteLegacyReading(_ reading: TarotReadingLegacy) {
        var readings = fetchLegacyReadings()
        readings.removeAll { $0.id == reading.id }
        if let encoded = try? JSONEncoder().encode(readings) {
            UserDefaults.standard.set(encoded, forKey: legacyReadingsKey)
        }
    }
}
// MARK: - Protocol for unified reading interface

protocol ReadingProtocol {
    var id: UUID { get }
    var date: Date { get }
    var spreadType: String { get }
    var questionAudioPath: String? { get }
    var readingAudioPath: String? { get }
    var cardIds: [String] { get }
    var cardReversals: [Bool] { get }
    var hashtags: [String] { get }
    var notes: String? { get }
}

@available(iOS 17.0, *)
extension TarotReading: ReadingProtocol {}

extension TarotReadingLegacy: ReadingProtocol {}

// MARK: - Errors

enum PersistenceError: LocalizedError {
    case contextUnavailable
    
    var errorDescription: String? {
        switch self {
        case .contextUnavailable:
            return "데이터 저장소에 접근할 수 없습니다"
        }
    }
}

