import Foundation

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
            throw FirestoreError.parseFailed(data: str)
        }
        return decoder
    }()
}
