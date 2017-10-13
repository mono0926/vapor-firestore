import Vapor
import Console
import Foundation
import HTTP

public protocol FirestoreClient {
    func get<T: Codable>(authToken: String,
                         path: String) throws -> T
    func post<T: Codable>(authToken: String,
                          path: String,
                          body: T) throws -> Document<T>

    func patch<T: Codable>(authToken: String,
                           path: String,
                           body: T) throws -> Document<T>
    func delete(authToken: String,
                path: String) throws
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

    public func get<T: Codable>(authToken: String,
                                path: String) throws -> T {
        let response = try client.get(
            baseUrl.appendingPathComponent(path).absoluteString,
            createHeaders(authToken: authToken))
        let bytes = response.body.bytes ?? []
        logger.debug(bytes.makeString())
        return try! JSONDecoder.firestore.decode(T.self, from: Data(bytes: bytes))
    }

    public func post<T: Codable>(authToken: String,
                                 path: String,
                                 body: T) throws -> Document<T> {
        let data = try JSONEncoder.firestore.encode(["fields": body])
        let response = try client.post(
            baseUrl.appendingPathComponent(path).absoluteString,
            createHeaders(authToken: authToken),
            Body.data(data.makeBytes()))
        let bytes = response.body.bytes ?? []
        logger.debug(bytes.makeString())
        return try JSONDecoder.firestore.decode(Document<T>.self, from: Data(bytes: bytes))
    }

    public func patch<T: Codable>(authToken: String,
                                  path: String,
                                  body: T) throws -> Document<T> {
        let data = try JSONEncoder.firestore.encode(["fields": body])
        let response = try client.patch(
            baseUrl.appendingPathComponent(path).absoluteString,
            createHeaders(authToken: authToken),
            Body.data(data.makeBytes()))
        let bytes = response.body.bytes ?? []
        logger.debug(bytes.makeString())
        return try JSONDecoder.firestore.decode(Document<T>.self, from: Data(bytes: bytes))
    }

    public func delete(authToken: String,
                       path: String) throws {
        let response = try client.delete(
            baseUrl.appendingPathComponent(path).absoluteString,
            createHeaders(authToken: authToken))
        let bytes = response.body.bytes ?? []
        logger.debug(bytes.makeString())
    }

    private func createHeaders(authToken: String) -> [HeaderKey: String] {
        return ["Authorization": "Bearer \(authToken)"]
    }
}





