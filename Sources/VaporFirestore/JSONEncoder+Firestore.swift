import Foundation

extension JSONEncoder {
    static let firestore: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.iso8601)
        return encoder
    }()
}
