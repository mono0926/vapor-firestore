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

    func testPost() throws {
        let fields = Fields(name: StringValue("dog"),
                           location: GeoPointValue.init(latitude: 1, longitude: 2),
                           age: IntegerValue(1),
                           isDog: BooleanValue(true),
                           info: MapValue(Info(foo: StringValue("bar"))),
                           lists: ArrayValue([IntegerValue(1), IntegerValue(2)]),
                           empty: NullValue(),
                           now: TimestampValue(Date()),
                           ref: ReferenceValue("projects/ighost-dev/databases/(default)/documents/test-collections/4IzJ67nUvIZ12VxVwCB0")
        )
        let result = try target.post(authToken: authToken,
                                     path: "test-collections",
                                     body: fields)
        print(result)
    }


    static var allTests = [
        ("testGetCollection", testGetCollection),
        ("testGetDocument", testGetDocument),
    ]
}
