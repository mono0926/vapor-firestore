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

public struct Collection<T: Codable>: Codable {
    public let documents: [Document<T>]
}

public struct Document<T: Codable>: Codable {
    public let name: String
    public let createTime: Date
    public let updateTime: Date
    public let fields: T?
}

public struct MapValue<T: Codable>: Codable {
    public let mapValue: Map<T>
    public init(_ value: T) {
        mapValue = Map(fields: value)
    }
}

public struct Map<T: Codable>: Codable {
    public let fields: T
}

public struct ArrayValue<T: Codable>: Codable {
    public let arrayValue: VaporFirestore.Array<T>
    public init(_ values: [T]) {
        arrayValue = VaporFirestore.Array(values: values)
    }
}

public struct Array<T: Codable>: Codable {
    public let values: [T]
}

public struct StringValue: Codable {
    public let stringValue: String
    public init(_ value: String) {
        stringValue = value
    }
}

public struct BooleanValue: Codable {
    public let booleanValue: Bool
    public init(_ value: Bool) {
        booleanValue = value
    }
}

public struct IntegerValue: Codable {
    private let _integerValue: String
    public var integerValue: Int { return Int(_integerValue) ?? 0 }
    enum CodingKeys: String, CodingKey {
        case _integerValue = "integerValue"
    }
    public init(_ value: Int) {
        _integerValue = String(value)
    }
}

public struct GeoPointValue: Codable {
    public let geoPointValue: GeoPoint
    public init(latitude: Double, longitude: Double) {
        geoPointValue = GeoPoint(latitude: latitude, longitude: longitude)
    }
}

public struct GeoPoint: Codable {
    public let latitude: Double
    public let longitude: Double
}

public struct NullValue: Codable {
    public let nullValue = 0
    public init() {}
}

public struct TimestampValue: Codable {
    public let timestampValue: Date
    public init(_ value: Date) {
        timestampValue = value
    }
}

public struct ReferenceValue: Codable {
    public let referenceValue: String
    public init(_ value: String) {
        referenceValue = value
    }
}

extension JSONDecoder {
    static let firestore: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { (decoder: Decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            if let date = DateFormatter.iso8601.date(from: str) {
                return date
            }
            if let date = DateFormatter.iso8601WithoutMilliseconds.date(from: str) {
                return date
            }
            throw NSError()
        }
        return decoder
    }()
}

extension JSONEncoder {
    static let firestore: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.iso8601)
        return encoder
    }()
}

extension DateFormatter {
    static let iso8601WithoutMilliseconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()
}

