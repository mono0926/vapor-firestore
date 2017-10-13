import XCTest
import VaporFirestore

struct Fields: Codable {
    var name: StringValue
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
    private let target: FirestoreClient = FireStoreVaporClient(projectId: "ighost-dev")
    private let authToken = "YOUR_AUTH_TOKEN"
    private let collection = "test-collections"
    func test() throws {
        var fields = Fields(name: StringValue("dog"),
                            location: GeoPointValue.init(latitude: 1, longitude: 2),
                            age: IntegerValue(1),
                            isDog: BooleanValue(true),
                            info: MapValue(Info(foo: StringValue("bar"))),
                            lists: ArrayValue([IntegerValue(1), IntegerValue(2)]),
                            empty: NullValue(),
                            now: TimestampValue(Date()),
                            ref: ReferenceValue("projects/ighost-dev/databases/(default)/documents/test-collections/4IzJ67nUvIZ12VxVwCB0")
        )

        // POST
        let postResponse = try target.post(authToken: authToken,
                                     path: collection,
                                     body: fields)
        let fieldsResponse1 = postResponse.fields!
        XCTAssertEqual(fieldsResponse1.name.stringValue, "dog")

        // PATCH
        fields.name = StringValue("dog2")
        let patchResponse = try target.patch(authToken: authToken,
                                      path: "\(collection)/\(postResponse.id)",
                                      body: fields)
        let fieldsResponse2 = patchResponse.fields!
        XCTAssertEqual(fieldsResponse2.name.stringValue, "dog2")

        // GET Document
        let getResponse1: Document<Fields> = try target.get(authToken: authToken,
                                                      path: "\(collection)/\(postResponse.id)")
        let fieldsRespons3 = getResponse1.fields!
        XCTAssertEqual(fieldsRespons3.name.stringValue, "dog2")

        // GET Collection
        let getResponse2: VaporFirestore.Collection<Fields> = try target.get(authToken: authToken,
                                                                             path: collection)
        let fieldsRespons4 = getResponse2.documents.filter { $0.id == postResponse.id }.first!.fields!
        XCTAssertEqual(fieldsRespons4.name.stringValue, "dog2")

        // DELETE
        try target.delete(authToken: authToken,
                          path: "\(collection)/\(postResponse.id)")

        // GET Document
        XCTAssertThrowsError(try target.get(authToken: authToken, path: "\(collection)/\(postResponse.id)") as Document<Fields>) { error in
            if case FirestoreError.response(let error) = error {
                XCTAssertEqual(error.code, 404)
                XCTAssertEqual(error.message, "Document \"projects/ighost-dev/databases/(default)/documents/test-collections/\(postResponse.id)\" not found.")
                XCTAssertEqual(error.status, "NOT_FOUND")
            } else {
                XCTFail()
            }
        }
    }

    static var allTests = [
        ("test", test),
    ]
}
