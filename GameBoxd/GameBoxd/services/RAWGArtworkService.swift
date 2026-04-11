import Foundation

struct RAWGGameArtworkMatch {
    let imageURLString: String?
    let genres: [String]
    let platformDisplay: String?
    let rating: Double?
    let releaseYear: Int?
}

protocol RAWGArtworkServicing {
    var isConfigured: Bool { get }
    func enrich(games: [HomeGame]) async -> [HomeGame]
}

final class RAWGArtworkService: RAWGArtworkServicing {
    static let shared = RAWGArtworkService()

    private init() {}

    var isConfigured: Bool {
        GameAPIKeyStore.hasAPIKey
    }

    func enrich(games: [HomeGame]) async -> [HomeGame] {
        guard let apiKey = GameAPIKeyStore.apiKey else { return games }

        var enrichedGames: [HomeGame] = []
        enrichedGames.reserveCapacity(games.count)

        for game in games {
            guard let remoteMatch = try? await fetchBestMatch(for: game.title, apiKey: apiKey) else {
                enrichedGames.append(game)
                continue
            }

            enrichedGames.append(game.applying(remoteMatch: remoteMatch))
        }

        return enrichedGames
    }

    private func fetchBestMatch(for title: String, apiKey: String) async throws -> RAWGGameArtworkMatch? {
        var components = URLComponents(string: "https://api.rawg.io/api/games")
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "search", value: title),
            URLQueryItem(name: "search_precise", value: "true"),
            URLQueryItem(name: "page_size", value: "1")
        ]

        guard let url = components?.url else { return nil }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard
            let httpResponse = response as? HTTPURLResponse,
            200..<300 ~= httpResponse.statusCode
        else {
            return nil
        }

        let decodedResponse = try JSONDecoder().decode(RAWGSearchResponse.self, from: data)
        guard let result = decodedResponse.results.first else {
            return nil
        }

        return RAWGGameArtworkMatch(
            imageURLString: result.backgroundImage,
            genres: (result.genres ?? []).map(\.name),
            platformDisplay: result.platformDisplay,
            rating: result.rating,
            releaseYear: result.releaseYear
        )
    }
}

private struct RAWGSearchResponse: Decodable {
    let results: [RAWGGame]
}

private struct RAWGGame: Decodable {
    let backgroundImage: String?
    let genres: [RAWGNamedValue]?
    let parentPlatforms: [RAWGPlatformWrapper]?
    let rating: Double?
    let released: String?

    enum CodingKeys: String, CodingKey {
        case backgroundImage = "background_image"
        case genres
        case parentPlatforms = "parent_platforms"
        case rating
        case released
    }

    var platformDisplay: String? {
        let names = (parentPlatforms ?? []).map(\.platform.name)
        guard !names.isEmpty else { return nil }
        return names.joined(separator: ", ")
    }

    var releaseYear: Int? {
        guard let released else { return nil }
        return Int(released.prefix(4))
    }
}

private struct RAWGNamedValue: Decodable {
    let name: String
}

private struct RAWGPlatformWrapper: Decodable {
    let platform: RAWGNamedValue
}
