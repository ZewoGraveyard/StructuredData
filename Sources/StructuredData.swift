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

    public static func from(value: Bool) -> StructuredData {
        return .boolValue(value)
    }

    public static func from(value: Double) -> StructuredData {
        return .numberValue(value)
    }

    public static func from(value: Int) -> StructuredData {
        return .numberValue(Double(value))
    }

    public static func from(value: String) -> StructuredData {
        return .stringValue(value)
    }

    public static func from(value: Data) -> StructuredData {
        return .binaryValue(value)
    }

    public static func from(value: [StructuredData]) -> StructuredData {
        return .arrayValue(value)
    }

    public static func from(value: [String: StructuredData]) -> StructuredData {
        return .dictionaryValue(value)
    }

    public var isBool: Bool {
        switch self {
        case .boolValue: return true
        default: return false
        }
    }

    public var isNumber: Bool {
        switch self {
        case .numberValue: return true
        default: return false
        }
    }

    public var isString: Bool {
        switch self {
        case .stringValue: return true
        default: return false
        }
    }

    public var isBinary: Bool {
        switch self {
        case .binaryValue: return true
        default: return false
        }
    }

    public var isArray: Bool {
        switch self {
        case .arrayValue: return true
        default: return false
        }
    }

    public var isDictionary: Bool {
        switch self {
        case .dictionaryValue: return true
        default: return false
        }
    }

    public var bool: Bool? {
        switch self {
        case .boolValue(let b): return b
        default: return nil
        }
    }

    public var double: Double? {
        switch self {
        case .numberValue(let n): return n
        default: return nil
        }
    }

    public var int: Int? {
        if let v = double {
            return Int(v)
        }
        return nil
    }

    public var uint: UInt? {
        if let v = double {
            return UInt(v)
        }
        return nil
    }

    public var string: String? {
        switch self {
        case .stringValue(let s): return s
        default: return nil
        }
    }

    public var binary: Data? {
        switch self {
        case .binaryValue(let d): return d
        default: return nil
        }
    }

    public var array: [StructuredData]? {
        switch self {
        case .arrayValue(let array): return array
        default: return nil
        }
    }

    public var dictionary: [String: StructuredData]? {
        switch self {
        case .dictionaryValue(let dictionary): return dictionary
        default: return nil
        }
    }

    public func get<T>() -> T? {
        switch self {
        case nullValue:
            return nil
        case boolValue(let bool):
            return bool as? T
        case numberValue(let number):
            return number as? T
        case stringValue(let string):
            return string as? T
        case binaryValue(let binary):
            return binary as? T
        case arrayValue(let array):
            return array as? T
        case dictionaryValue(let dictionary):
            return dictionary as? T
        }
    }

    public func get<T>(key: String) throws -> T {
        if let value = self[key] {
            return try value.get()
        }

        throw Error.incompatibleType
    }

    public func get<T>() throws -> T {
        switch self {
        case boolValue(let boolean):
            if let value = boolean as? T {
                return value
            }

        case numberValue(let number):
            if let value = number as? T {
                return value
            }

        case stringValue(let string):
            if let value = string as? T {
                return value
            }

        case .binaryValue(let binary):
            if let value = binary as? T {
                return value
            }

        case arrayValue(let array):
            if let value = array as? T {
                return value
            }

        case dictionaryValue(let dictionary):
            if let value = dictionary as? T {
                return value
            }

        default: break
        }

        throw Error.incompatibleType
    }

    public func asBool() throws -> Bool {
        if let bool = bool {
            return bool
        }
        throw Error.incompatibleType
    }

    public func asDouble() throws -> Double {
        if let double = double {
            return double
        }
        throw Error.incompatibleType
    }

    public func asInt() throws -> Int {
        if let int = int {
            return int
        }
        throw Error.incompatibleType
    }

    public func asUInt() throws -> UInt {
        if let uint = uint {
            return UInt(uint)
        }
        throw Error.incompatibleType
    }

    public func asString() throws -> String {
        if let string = string {
            return string
        }
        throw Error.incompatibleType
    }

    public func asBinary() throws -> Data {
        if let binary = binary {
            return binary
        }
        throw Error.incompatibleType
    }

    public func asArray() throws -> [StructuredData] {
        if let array = array {
            return array
        }
        throw Error.incompatibleType
    }

    public func asDictionary() throws -> [String: StructuredData] {
        if let dictionary = dictionary {
            return dictionary
        }
        throw Error.incompatibleType
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
    switch lhs {
    case .nullValue:
        switch rhs {
        case .nullValue: return true
        default: return false
        }
    case .boolValue(let lhsValue):
        switch rhs {
        case .boolValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .stringValue(let lhsValue):
        switch rhs {
        case .stringValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .binaryValue(let lhsValue):
        switch rhs {
        case .binaryValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .numberValue(let lhsValue):
        switch rhs {
        case .numberValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .arrayValue(let lhsValue):
        switch rhs {
        case .arrayValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .dictionaryValue(let lhsValue):
        switch rhs {
        case .dictionaryValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
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
        var string = ""

        for s in strings {
            string += s.string!
        }

        self = .stringValue(String(string))
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

        for pair in elements {
            dictionary[pair.0] = pair.1
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
