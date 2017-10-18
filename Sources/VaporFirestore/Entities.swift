import Foundation

public struct Collection<T: Codable>: Codable {
    public let documents: [Document<T>]
}

public struct Document<T: Codable>: Codable {
    public let name: String
    public let createTime: Date
    public let updateTime: Date
    public let fields: T?
    public var id: String { return String(name.split(separator: "/").last ?? "") }
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
    init(_ value: String) {
        referenceValue = value
    }
}
