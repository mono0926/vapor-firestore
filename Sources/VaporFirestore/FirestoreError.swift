import Foundation

public struct FirestoreErrorResponseBody: Codable {
    public let code: Int
    public let message: String
    public let status: String
}

public enum FirestoreError: Error {
    case
    parseFailed(data: String),
    response(error: FirestoreErrorResponseBody)
}
