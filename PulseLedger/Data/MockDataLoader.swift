import Foundation

enum MockDataLoaderError: Error, Sendable {
    case fileNotFound
    case decodeFailed(Error)
}

/// Single source of truth: reads `mock_data.json` from the app bundle once per load.
final class MockDataLoader: Sendable {
    private let bundle: Bundle
    private let fileName: String
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main, fileName: String = "mock_data") {
        self.bundle = bundle
        self.fileName = fileName
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func load() throws -> MockDataRootDTO {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw MockDataLoaderError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        do {
            return try decoder.decode(MockDataRootDTO.self, from: data)
        } catch {
            throw MockDataLoaderError.decodeFailed(error)
        }
    }
}
