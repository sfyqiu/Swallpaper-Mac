import Foundation

// MARK: - 动漫模块已删除，以下为编译兼容 stub

struct AnimeSearchResult: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let coverURL: URL?
    let provider: String
    let detailURL: String
    let description: String?
    let tags: [AnimeTag]
    let episodes: [AnimeEpisodeStub]

    init(id: String, title: String, coverURL: URL? = nil, provider: String = "", detailURL: String = "", description: String? = nil, tags: [AnimeTag] = [], episodes: [AnimeEpisodeStub] = []) {
        self.id = id; self.title = title; self.coverURL = coverURL; self.provider = provider
        self.detailURL = detailURL; self.description = description; self.tags = tags; self.episodes = episodes
    }
}

struct AnimeTag: Codable, Hashable {
    let name: String
    let count: Int?
}

struct AnimeEpisodeStub: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let url: String
}

@MainActor
final class AnimeFavoriteStore: ObservableObject {
    static let shared = AnimeFavoriteStore()
    @Published var favorites: [AnimeSearchResult] = []
    var allFavorites: [AnimeSearchResult] { favorites }
    func removeFavorite(animeId: String) { favorites.removeAll { $0.id == animeId } }
    func restoreSavedData() {}
}

@MainActor
final class AnimeProgressStore: ObservableObject {
    static let shared = AnimeProgressStore()
    var animeSummaries: [String: AnimeWatchSummary] = [:]
    func restoreSavedData() {}
}

struct AnimeWatchSummary {
    let watchedCount: Int
    let totalCount: Int
    let lastWatchedEpisode: String?
}

// MARK: - 其他缺失类型 stub

enum AnimeParserError: LocalizedError {
    case parseError(String)
    var errorDescription: String? { "\(self)" }
}

@MainActor
final class AnimeRuleStore: ObservableObject {
    static let shared = AnimeRuleStore()
    func clearInMemoryCache() async {}
    func allRules() async -> [AnimeRuleStub] { [] }
    func installRule(from url: URL) async throws -> AnimeRuleStub { AnimeRuleStub(id: "", name: "") }
    func removeRule(id: String) async throws {}
}

struct AnimeRuleStub: Identifiable {
    let id: String
    let name: String
}

@MainActor
final class AnimeWindowManager {
    static let shared = AnimeWindowManager()
    func closeAllWindowsForMemoryRelease() {}
}

@MainActor
final class AnimeVideoExtractor {
    static let shared = AnimeVideoExtractor()
    func cancel() {}
}
