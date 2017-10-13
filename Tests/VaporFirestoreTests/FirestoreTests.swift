import XCTest
import VaporFirestore

struct Fields: Codable {
    let name: StringValue
    let location: GeoPointValue
    let age: IntegerValue
    let isDog: BooleanValue
    let info: MapValue<Info>
    let lists: ArrayValue<IntegerValue>
    let empty: NullValue
    let now: TimestampValue
    let ref: ReferenceValue
}

struct Info: Codable {
    let foo: StringValue
}

class VaporFirestoreTests: XCTestCase {
    private let target = FireStoreVaporClient(projectId: "ighost-dev")
    private let authToken = "YOUR_AUTH_TOKEN"
    func testGetCollection() throws {
        let result: VaporFirestore.Collection<Fields> = try target.get(authToken: authToken,
                                                                       path: "test-collections")
        result.documents.forEach { doc in
            print(doc)
        }
    }
    func testGetDocument() throws {
        let result: Document<Fields> = try target.get(authToken: authToken,
                                                                       path: "test-collections/4IzJ67nUvIZ12VxVwCB0")
        print(result)
    }


    static var allTests = [
        ("testGetCollection", testGetCollection),
        ("testGetDocument", testGetDocument),
    ]
}
