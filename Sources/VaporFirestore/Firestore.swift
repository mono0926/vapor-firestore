import Vapor
import Console
import Foundation

public protocol FirestoreClient {
    // TODO: あとで
}

public struct FireStoreVaporClient: FirestoreClient {
    private let projectId: String
    private let baseUrl: URL
    private let client: ClientFactoryProtocol
    private let logger: LogProtocol

    public init(projectId: String,
                client: ClientFactoryProtocol = EngineClientFactory(),
                logger: LogProtocol = ConsoleLogger(Terminal(arguments: []))) {
        self.projectId = projectId
        self.baseUrl = URL(string: "https://firestore.googleapis.com/v1beta1/projects/\(projectId)/databases/(default)/documents/")!
        self.client = client
        self.logger = logger
    }

    public func get<T: Codable>(authToken: String, path: String) throws -> Root<T> {
        let response = try client.get(
            baseUrl.appendingPathComponent(path).absoluteString,
            ["Authorization": "Bearer \(authToken)",
                "Content-Type": "application/json"])
        logger.debug((response.body.bytes ?? []).makeString())
        return try JSONDecoder.iso8601.decode(Root<T>.self, from: Data(bytes: response.body.bytes ?? []))
    }
}

public struct Root<T: Codable>: Codable {
    public let documents: [Document<T>]
}

public struct Document<T: Codable>: Codable {
    public let name: String
    public let createTime: Date
    public let updateTime: Date
    public let fields: T?
}

extension JSONDecoder {
    static let iso8601: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
        return decoder
    }()
}
