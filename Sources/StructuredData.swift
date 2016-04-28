@_exported import C7

public protocol StructuredDataInitializable {
    init(structuredData: StructuredData) throws
}

public protocol StructuredDataRepresentable {
    var structuredData: StructuredData { get }
}

public protocol StructuredDataConvertible: StructuredDataInitializable, StructuredDataRepresentable {}

public protocol StructuredDataParser {
    func parse(_ data: Data) throws -> StructuredData
}

public extension StructuredDataParser {
    public func parse(_ convertible: DataConvertible) throws -> StructuredData {
        return try parse(convertible.data)
    }
}

public protocol StructuredDataSerializer {
    func serialize(_ structuredData: StructuredData) throws -> Data
}

public enum StructuredData {
    case nullValue
    case boolValue(Bool)
    case numberValue(Double)
    case stringValue(String)
    case binaryValue(Data)
    case arrayValue([StructuredData])
    case dictionaryValue([String: StructuredData])

    public enum Error: ErrorProtocol {
        case incompatibleType
    }

    public static func from(_ value: Bool) -> StructuredData {
        return .boolValue(value)
    }

    public static func from(_ value: Double) -> StructuredData {
        return .numberValue(value)
    }

    public static func from(_ value: Int) -> StructuredData {
        return .numberValue(Double(value))
    }

    public static func from(_ value: String) -> StructuredData {
        return .stringValue(value)
    }

    public static func from(_ value: Data) -> StructuredData {
        return .binaryValue(value)
    }

    public static func from(_ value: [StructuredData]) -> StructuredData {
        return .arrayValue(value)
    }

    public static func from(_ value: [String: StructuredData]) -> StructuredData {
        return .dictionaryValue(value)
    }

    public var isBool: Bool {
        if case .boolValue = self {
            return true
        }
        return false
    }

    public var isNumber: Bool {
        if case .numberValue = self {
            return true
        }
        return false
    }

    public var isString: Bool {
        if case .stringValue = self {
            return true
        }
        return false
    }

    public var isBinary: Bool {
        if case .binaryValue = self {
            return true
        }
        return false
    }

    public var isArray: Bool {
        if case .arrayValue = self {
            return true
        }
        return false
    }

    public var isDictionary: Bool {
        if case .dictionaryValue = self {
            return true
        }
        return false
    }

    public var bool: Bool? {
        if case .boolValue(let b) = self {
            return b
        }
        return nil
    }

    public var double: Double? {
        if case .numberValue(let d) = self {
            return d
        }
        return nil
    }

    public var int: Int? {
        return double.flatMap { Int($0) }
    }

    public var uint: UInt? {
        return double.flatMap { UInt($0) }
    }

    public var string: String? {
        if case .stringValue(let s) = self {
            return s
        }
        return nil
    }

    public var binary: Data? {
        if case .binaryValue(let d) = self {
            return d
        }
        return nil
    }

    public var array: [StructuredData]? {
        if case .arrayValue(let a) = self {
            return a
        }
        return nil
    }

    public var dictionary: [String: StructuredData]? {
        if case .dictionaryValue(let dic) = self {
            return dic
        }
        return nil
    }

    public func get<T>() -> T? {
        return try? get()
    }

    public func get<T>(_ key: String) throws -> T {
        if let value = self[key] {
            return try value.get()
        }

        throw Error.incompatibleType
    }

    public func get<T>() throws -> T {
        switch self {
        case boolValue(let value as T):
            return value

        case numberValue(let value as T):
            return value

        case stringValue(let value as T):
            return value

        case .binaryValue(let value as T):
            return value

        case arrayValue(let value as T):
            return value

        case dictionaryValue(let value as T):
            return value

        default: break
        }

        throw Error.incompatibleType
    }

    public func asBool() throws -> Bool {
        return try get()
    }

    public func asDouble() throws -> Double {
        return try get()
    }

    public func asInt() throws -> Int {
        return try get()
    }

    public func asUInt() throws -> UInt {
        return try get()
    }

    public func asString() throws -> String {
        return try get()
    }

    public func asBinary() throws -> Data {
        return try get()
    }

    public func asArray() throws -> [StructuredData] {
        return try get()
    }

    public func asDictionary() throws -> [String: StructuredData] {
        return try get()
    }

    public subscript(index: Int) -> StructuredData? {
        get {
            if let array = array where index > 0  && index < array.count {
                return array[index]
            }
            return nil
        }

        set(structuredData) {
            switch self {
            case .arrayValue(let array):
                var array = array
                if index > 0 && index < array.count {
                    if let structuredData = structuredData {
                        array[index] = structuredData
                    } else {
                        array[index] = .nullValue
                    }
                    self = .arrayValue(array)
                }
            default: break
            }
        }
    }

    public subscript(key: String) -> StructuredData? {
        get {
            return dictionary?[key]
        }

        set(structuredData) {
            switch self {
            case .dictionaryValue(let dictionary):
                var dictionary = dictionary
                dictionary[key] = structuredData
                self = .dictionaryValue(dictionary)
            default: break
            }
        }
    }
}

extension StructuredData: Equatable {}

public func ==(lhs: StructuredData, rhs: StructuredData) -> Bool {
    switch (lhs, rhs) {
        case (.nullValue, .nullValue):
            return true

        case (.boolValue(let l), .boolValue(let r)) where l == r:
            return true

        case (.stringValue(let l), .stringValue(let r)) where l == r:
            return true

        case (.binaryValue(let l), .binaryValue(let r)) where l == r:
            return true

        case (.numberValue(let l), .numberValue(let r)) where l == r:
            return true

        case (.arrayValue(let l), .arrayValue(let r)) where l == r:
            return true

        case (.dictionaryValue(let l), .dictionaryValue(let r)) where l == r:
            return true

        default:
            return false
    }
}

extension StructuredData: NilLiteralConvertible {
    public init(nilLiteral value: Void) {
        self = .nullValue
    }
}

extension StructuredData: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .boolValue(value)
    }
}

extension StructuredData: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .numberValue(Double(value))
    }
}

extension StructuredData: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .numberValue(Double(value))
    }
}

extension StructuredData: StringLiteralConvertible {
    public init(unicodeScalarLiteral value: String) {
        self = .stringValue(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .stringValue(value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self = .stringValue(value)
    }
}

extension StructuredData: StringInterpolationConvertible {
    public init(stringInterpolation strings: StructuredData...) {
        let s = strings.reduce("") { $0 + ($1.string ?? "") }
        self = .stringValue(s)
    }

    public init<T>(stringInterpolationSegment expr: T) {
        self = .stringValue(String(expr))
    }
}

extension StructuredData: ArrayLiteralConvertible {
    public init(arrayLiteral elements: StructuredData...) {
        self = .arrayValue(elements)
    }
}

extension StructuredData: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, StructuredData)...) {
        var dictionary = [String: StructuredData](minimumCapacity: elements.count)

        for (key, value) in elements {
            dictionary[key] = value
        }

        self = .dictionaryValue(dictionary)
    }
}

extension StructuredData: CustomStringConvertible {
    public var description: String {
        var indentLevel = 0

        func serialize(_ data: StructuredData) -> String {
            switch data {
            case .nullValue: return "null"
            case .boolValue(let b): return b ? "true" : "false"
            case .numberValue(let n): return serialize(number: n)
            case .stringValue(let s): return escape(s)
            case .binaryValue(let d): return escape(d.hexadecimalDescription)
            case .arrayValue(let a): return serialize(array: a)
            case .dictionaryValue(let o): return serialize(object: o)
            }
        }

        func serialize(number: Double) -> String {
            if number == Double(Int64(number)) {
                return Int64(number).description
            } else {
                return number.description
            }
        }

        func serialize(array: [StructuredData]) -> String {
            var s = "["
            indentLevel += 1

            for i in 0 ..< array.count {
                s += "\n"
                s += indent()
                s += serialize(array[i])

                if i != (array.count - 1) {
                    s += ","
                }
            }

            indentLevel -= 1
            return s + "\n" + indent() + "]"
        }

        func serialize(object: [String: StructuredData]) -> String {
            var s = "{"
            indentLevel += 1
            var i = 0

            for (key, value) in object {
                s += "\n"
                s += indent()
                s += "\(escape(key)): \(serialize(value))"

                if i != (object.count - 1) {
                    s += ","
                }
                i += 1
            }

            indentLevel -= 1
            return s + "\n" + indent() + "}"
        }

        func indent() -> String {
            var s = ""

            for _ in 0 ..< indentLevel {
                s += "    "
            }

            return s
        }

        return serialize(self)
    }
}

func escape(_ source: String) -> String {
    var s = "\""

    for c in source.characters {
        if let escapedSymbol = escapeMapping[c] {
            s.append(escapedSymbol)
        } else {
            s.append(c)
        }
    }

    s.append("\"")

    return s
}

let escapeMapping: [Character: String] = [
    "\r": "\\r",
    "\n": "\\n",
    "\t": "\\t",
    "\\": "\\\\",
    "\"": "\\\"",

    "\u{2028}": "\\u2028",
    "\u{2029}": "\\u2029",

    "\r\n": "\\r\\n"
]
