import Foundation

public enum MockDataLoaderError: Error, Sendable {
    case fileNotFound
    case decodeFailed(Error)
}

/// Reads `mock_data.json` from the PulseCore bundle.
public final class MockDataLoader: Sendable {
    private let bundle: Bundle
    private let fileName: String
    private let decoder: JSONDecoder

    public init(bundle: Bundle? = nil, fileName: String = "mock_data") {
        self.bundle = bundle ?? Bundle.module
        self.fileName = fileName
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func load() throws -> MockDataRootDTO {
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
