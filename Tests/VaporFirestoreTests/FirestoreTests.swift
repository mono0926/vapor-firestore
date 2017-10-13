import XCTest
import VaporFirestore

struct Empty: Codable {}

class VaporFirestoreTests: XCTestCase {
    private let target = FireStoreVaporClient(projectId: "ighost-dev")
    func testGet() throws {
        let result: Root<Empty> = try target.get(authToken: "YOUR_AUTH_TOKEN",
                                                 path: "test-collections")
        print(result)
    }


    static var allTests = [
        ("testGet", testGet),
    ]
}
