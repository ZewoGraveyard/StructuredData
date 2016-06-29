// StructuredData.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2016 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@_exported import C7

public enum StructuredDataError: ErrorProtocol {
    case incompatibleType
    case notStructuredDataInitializable(Any.Type)
    case notStructuredDataRepresentable(Any.Type)
    case notStructuredDataDictionaryKeyRepresentable(Any.Type)
    case cannotInitialize(type: Any.Type, from: Any.Type)
}

protocol StructuredDataConvertible : StructuredDataInitializable, StructuredDataFallibleRepresentable {}

// MARK: Parser/Serializer Protocols
public protocol StructuredDataParser {
    func parse(_ data: Data) throws -> StructuredData
}

extension StructuredDataParser {
    public func parse(_ convertible: DataConvertible) throws -> StructuredData {
        return try parse(convertible.data)
    }
}

public protocol StructuredDataSerializer {
    func serialize(_ structuredData: StructuredData) throws -> Data
}

// MARK: Initializers
extension StructuredData {
    public init(_ value: StructuredDataRepresentable) {
        self = value.structuredData
    }

    public init(_ values: [StructuredDataRepresentable]) {
        self = .array(values.map({$0.structuredData}))
    }

    public init(_ values: [String: StructuredDataRepresentable]) {
        var dictionary: [String: StructuredData] = [:]

        for (key, value) in values.map({($0.key, $0.value.structuredData)}) {
            dictionary[key] = value
        }

        self = .dictionary(dictionary)
    }

    public init<T: StructuredDataRepresentable>(_ value: T?) {
        self = value?.structuredData ?? .null
    }

    public init<T: StructuredDataRepresentable>(_ values: [T]?) {
        if let values = values {
            self = .array(values.map({$0.structuredData}))
        } else {
            self = .null
        }
    }

    public init<T: StructuredDataRepresentable>(_ values: [T?]?) {
        if let values = values {
            self = .array(values.map({$0?.structuredData ?? .null}))
        } else {
            self = .null
        }
    }

    public init<T: StructuredDataRepresentable>(_ values: [String: T]?) {
        if let values = values {
            var dictionary: [String: StructuredData] = [:]

            for (key, value) in values.map({($0.key, $0.value.structuredData)}) {
                dictionary[key] = value
            }

            self = .dictionary(dictionary)
        } else {
            self = .null
        }
    }

    public init<T: StructuredDataRepresentable>(_ values: [String: T?]?) {
        if let values = values {
            var dictionary: [String: StructuredData] = [:]

            for (key, value) in values.map({($0.key, $0.value?.structuredData ?? .null)}) {
                dictionary[key] = value
            }

            self = .dictionary(dictionary)
        } else {
            self = .null
        }
    }
}

// MARK: Type Inference
extension StructuredData {
    public static func infer<T: StructuredDataRepresentable>(_ value: T?) -> StructuredData {
        return StructuredData(value)
    }

    public static func infer<T: StructuredDataRepresentable>(_ values: [T]?) -> StructuredData {
        return StructuredData(values)
    }

    public static func infer<T: StructuredDataRepresentable>(_ values: [T?]?) -> StructuredData {
        return StructuredData(values)
    }

    public static func infer<T: StructuredDataRepresentable>(_ values: [String: T]?) -> StructuredData {
        return StructuredData(values)
    }

    public static func infer<T: StructuredDataRepresentable>(_ values: [String: T?]?) -> StructuredData {
        return StructuredData(values)
    }

    public static func infer(_ value: Bool) -> StructuredData {
        return .bool(value)
    }

    public static func infer(_ value: Double) -> StructuredData {
        return .double(value)
    }

    public static func infer(_ value: Int) -> StructuredData {
        return .int(value)
    }

    public static func infer(_ value: String) -> StructuredData {
        return .string(value)
    }

    public static func infer(_ value: Data) -> StructuredData {
        return .data(value)
    }

    public static func infer(_ value: [StructuredData]) -> StructuredData {
        return .array(value)
    }

    public static func infer(_ value: [String: StructuredData]) -> StructuredData {
        return .dictionary(value)
    }
}

// MARK: Getters/Setters
extension StructuredData {
    public func get<T>() throws -> T {
        switch self {
        case .bool(let value as T): return value
        case .int(let value as T): return value
        case .double(let value as T): return value
        case .string(let value as T): return value
        case .data(let value as T): return value
        case .array(let value as T): return value
        case .dictionary(let value as T): return value
        default: throw StructuredDataError.incompatibleType
        }
    }

    public func get<T>(_ index: Int) throws -> T {
        if let value = self[index] {
            return try value.get()
        }
        throw StructuredDataError.incompatibleType
    }

    public func get<T>(_ key: String) throws -> T {
        if let value = self[key] {
            return try value.get()
        }
        throw StructuredDataError.incompatibleType
    }

    public mutating func set(_ value: StructuredDataRepresentable, at key: String) throws {
        try set(value.structuredData, at: key)
    }

    public mutating func set(_ value: StructuredData, at index: Int) throws {
        switch self {
        case .array(let array):
            var array = array
            if index >= 0 && index < array.count {
                array[index] = value
                self = .array(array)
            }
        default:
            throw StructuredDataError.incompatibleType
        }
    }

    public mutating func set(_ value: StructuredDataRepresentable, at index: Int) throws {
        try set(value.structuredData, at: index)
    }

    public mutating func set(_ value: StructuredData?, at key: String) throws {
        switch self {
        case .dictionary(let dictionary):
            var dictionary = dictionary
            dictionary[key] = value
            self = .dictionary(dictionary)
        default:
            throw StructuredDataError.incompatibleType
        }
    }
}

// MARK: Subscripts
extension StructuredData {
    public subscript(index: Int) -> StructuredData? {
        get {
            guard let array = arrayValue where array.indices.contains(index) else {
                return nil
            }
            return array[index]
        }

        set(structuredData) {
            switch self {
            case .array(let array):
                var array = array
                if index >= 0 && index < array.count {
                    array[index] = structuredData ?? .null
                    self = .array(array)
                }
            default: break
            }
        }
    }

    public subscript(key: String) -> StructuredData? {
        get {
            return dictionaryValue?[key]
        }
        set(structuredData) {
            switch self {
            case .dictionary(let dictionary):
                var dictionary = dictionary
                dictionary[key] = structuredData
                self = .dictionary(dictionary)
            default: break
            }
        }
    }
}

// MARK: is<Type>
extension StructuredData {
    public var isBool: Bool {
        if case .bool = self {
            return true
        }
        return false
    }

    public var isDouble: Bool {
        if case .double = self {
            return true
        }
        return false
    }

    public var isInt: Bool {
        if case .int = self {
            return true
        }
        return false
    }

    public var isString: Bool {
        if case .string = self {
            return true
        }
        return false
    }

    public var isData: Bool {
        if case .data = self {
            return true
        }
        return false
    }

    public var isArray: Bool {
        if case .array = self {
            return true
        }
        return false
    }

    public var isDictionary: Bool {
        if case .dictionary = self {
            return true
        }
        return false
    }
}

// MARK: <type>Value
extension StructuredData {
    public var boolValue: Bool? {
        return try? get()
    }

    public var doubleValue: Double? {
        return try? get()
    }

    public var intValue: Int? {
        return try? get()
    }

    public var stringValue: String? {
        return try? get()
    }

    public var dataValue: Data? {
        return try? get()
    }

    public var arrayValue: [StructuredData]? {
        return try? get()
    }

    public var dictionaryValue: [String: StructuredData]? {
        return try? get()
    }
}

// MARK: as<type>
extension StructuredData {
    public func asBool(converting: Bool = false) throws -> Bool {
        guard converting else {
            return try get()
        }

        switch self {
        case .bool(let value):
            return value

        case .int(let value):
            switch value {
            case 0: return false
            case 1: return true
            default: throw StructuredDataError.incompatibleType
            }

        case .double(let value):
            return value != 0

        case .string(let value):
            switch value.lowercased() {
            case "true": return true
            case "false": return false
            default: throw StructuredDataError.incompatibleType
            }

        case .data(let value):
            return !value.isEmpty

        case .array(let value):
            return !value.isEmpty

        case .dictionary(let value):
            return !value.isEmpty

        case .null:
            return false
        }
    }

    public func asInt(converting: Bool = false) throws -> Int {
        guard converting else {
            return try get()
        }

        switch self {
        case .bool(let value):
            return value ? 1 : 0

        case .int(let value):
            return value

        case .double(let value):
            return Int(value)

        case .string(let value):
            if let int = Int(value) {
                return int
            }
            throw StructuredDataError.incompatibleType

        case .null:
            return 0

        default:
            throw StructuredDataError.incompatibleType
        }
    }

    public func asDouble(converting: Bool = false) throws -> Double {
        guard converting else {
            return try get()
        }

        switch self {
        case .bool(let value):
            return value ? 1.0 : 0.0

        case .int(let value):
            return Double(value)

        case .double(let value):
            return value

        case .string(let value):
            if let double = Double(value) {
                return double
            }
            throw StructuredDataError.incompatibleType

        case .null:
            return 0

        default:
            throw StructuredDataError.incompatibleType
        }
    }

    public func asString(converting: Bool = false) throws -> String {
        guard converting else {
            return try get()
        }

        switch self {
        case .bool(let value):
            return String(value)

        case .int(let value):
            return String(value)

        case .double(let value):
            return String(value)

        case .string(let value):
            return value

        case .data(let value):
            return String(value)

        case .array(let value):
            return String(value)

        case .dictionary(let value):
            return String(value)

        case .null:
            return "null"
        }
    }

    public func asData(converting: Bool = false) throws -> Data {
        guard converting else {
            return try get()
        }

        switch self {
        case .bool(let value):
            return value ? [0xff] : [0x00]

        case .string(let value):
            return Data(value)

        case .data(let value):
            return value

        case .null:
            return []

        default:
            throw StructuredDataError.incompatibleType
        }
    }

    public func asArray(converting: Bool = false) throws -> [StructuredData] {
        guard converting else {
            return try get()
        }

        switch self {
        case .array(let value):
            return value

        case .null:
            return []

        default:
            throw StructuredDataError.incompatibleType
        }
    }

    public func asDictionary(converting: Bool = false) throws -> [String: StructuredData] {
        guard converting else {
            return try get()
        }

        switch self {
        case .dictionary(let value):
            return value

        case .null:
            return [:]

        default:
            throw StructuredDataError.incompatibleType
        }
    }
}

// MARK: Equatable
extension StructuredData: Equatable {}

public func ==(lhs: StructuredData, rhs: StructuredData) -> Bool {
    switch (lhs, rhs) {
    case (.null, .null): return true
    case let (.int(l), .int(r)) where l == r: return true
    case let (.bool(l), .bool(r)) where l == r: return true
    case let (.string(l), .string(r)) where l == r: return true
    case let (.data(l), .data(r)) where l == r: return true
    case let (.double(l), .double(r)) where l == r: return true
    case let (.array(l), .array(r)) where l == r: return true
    case let (.dictionary(l), .dictionary(r)) where l == r: return true
    default: return false
    }
}

// MARK: Literal Convertibles
extension StructuredData: NilLiteralConvertible {
    public init(nilLiteral value: Void) {
        self = .null
    }
}

extension StructuredData: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension StructuredData: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}

extension StructuredData: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .double(value)
    }
}

extension StructuredData: StringLiteralConvertible {
    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension StructuredData: StringInterpolationConvertible {
    public init(stringInterpolation strings: StructuredData...) {
        self = .string(strings.reduce("") { $0 + ($1.stringValue ?? "") })
    }

    public init<T>(stringInterpolationSegment expr: T) {
        self = .string(String(expr))
    }
}

extension StructuredData: ArrayLiteralConvertible {
    public init(arrayLiteral elements: StructuredData...) {
        self = .array(elements)
    }
}

extension StructuredData: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, StructuredData)...) {
        var dictionary = [String: StructuredData](minimumCapacity: elements.count)

        for (key, value) in elements {
            dictionary[key] = value
        }

        self = .dictionary(dictionary)
    }
}

// MARK: CustomStringConvertible
extension StructuredData: CustomStringConvertible {
    public var description: String {
        var indentLevel = 0

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

        func serialize(_ data: StructuredData) -> String {
            switch data {
            case .null: return "null"
            case .bool(let b): return String(b)
            case .double(let n): return serialize(number: n)
            case .int(let n): return n.description
            case .string(let s): return escape(s)
            case .data(let d): return escape(d.hexadecimalDescription)
            case .array(let a): return serialize(array: a)
            case .dictionary(let o): return serialize(object: o)
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
            let spaceCount = indentLevel * 4
            return String(repeating: Character(" "), count: spaceCount)
        }

        return serialize(self)
    }
}
