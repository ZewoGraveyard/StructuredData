// InterchangeData.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
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

@_exported import Data

public protocol InterchangeDataParser {
    func parse(data: Data) throws -> InterchangeData
}

public extension InterchangeDataParser {
    public func parse(convertible: DataConvertible) throws -> InterchangeData {
        return try parse(convertible.xData)
    }
}

public protocol InterchangeDataSerializer {
    func serialize(interchangeData: InterchangeData) throws -> Data
}

public enum InterchangeData {
    case Null
    case Boolean(Bool)
    case Number(Double)
    case Text(String)
    case Binary(Data)
    case Array([InterchangeData])
    case Dictionary([String: InterchangeData])

    public enum Error: ErrorProtocol {
        case IncompatibleType
    }

    public static func from(value: Bool) -> InterchangeData {
        return .Boolean(value)
    }

    public static func from(value: Double) -> InterchangeData {
        return .Number(value)
    }

    public static func from(value: Int) -> InterchangeData {
        return .Number(Double(value))
    }

    public static func from(value: String) -> InterchangeData {
        return .Text(value)
    }

    public static func from(value: Data) -> InterchangeData {
        return .Binary(value)
    }

    public static func from(value: [InterchangeData]) -> InterchangeData {
        return .Array(value)
    }

    public static func from(value: [String: InterchangeData]) -> InterchangeData {
        return .Dictionary(value)
    }

    public var isBoolean: Bool {
        switch self {
        case .Boolean: return true
        default: return false
        }
    }

    public var isNumber: Bool {
        switch self {
        case .Number: return true
        default: return false
        }
    }

    public var isText: Bool {
        switch self {
        case .Text: return true
        default: return false
        }
    }

    public var isBinary: Bool {
        switch self {
        case .Binary: return true
        default: return false
        }
    }

    public var isArray: Bool {
        switch self {
        case .Array: return true
        default: return false
        }
    }

    public var isDictionary: Bool {
        switch self {
        case .Dictionary: return true
        default: return false
        }
    }

    public var boolean: Bool? {
        switch self {
        case .Boolean(let b): return b
        default: return nil
        }
    }

    public var double: Double? {
        switch self {
        case .Number(let n): return n
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

    public var text: String? {
        switch self {
        case .Text(let s): return s
        default: return nil
        }
    }

    public var binary: Data? {
        switch self {
        case .Binary(let d): return d
        default: return nil
        }
    }

    public var array: [InterchangeData]? {
        switch self {
        case .Array(let array): return array
        default: return nil
        }
    }

    public var dictionary: [String: InterchangeData]? {
        switch self {
        case .Dictionary(let dictionary): return dictionary
        default: return nil
        }
    }

    public func get<T>() -> T? {
        switch self {
        case Null:
            return nil
        case Boolean(let boolean):
            return boolean as? T
        case Number(let number):
            return number as? T
        case Text(let text):
            return text as? T
        case Binary(let binary):
            return binary as? T
        case Array(let array):
            return array as? T
        case Dictionary(let dictionary):
            return dictionary as? T
        }
    }

    public func get<T>(key: String) throws -> T {
        if let value = self[key] {
            return try value.get()
        }

        throw Error.IncompatibleType
    }

    public func get<T>() throws -> T {
        switch self {
        case Boolean(let boolean):
            if let value = boolean as? T {
                return value
            }

        case Number(let number):
            if let value = number as? T {
                return value
            }

        case Text(let text):
            if let value = text as? T {
                return value
            }

        case .Binary(let binary):
            if let value = binary as? T {
                return value
            }

        case Array(let array):
            if let value = array as? T {
                return value
            }

        case Dictionary(let dictionary):
            if let value = dictionary as? T {
                return value
            }

        default: break
        }

        throw Error.IncompatibleType
    }

    public func asBoolean() throws -> Bool {
        if let boolean = boolean {
            return boolean
        }
        throw Error.IncompatibleType
    }

    public func asDouble() throws -> Double {
        if let double = double {
            return double
        }
        throw Error.IncompatibleType
    }

    public func asInt() throws -> Int {
        if let int = int {
            return int
        }
        throw Error.IncompatibleType
    }

    public func asUInt() throws -> UInt {
        if let uint = uint {
            return UInt(uint)
        }
        throw Error.IncompatibleType
    }

    public func asText() throws -> String {
        if let text = text {
            return text
        }
        throw Error.IncompatibleType
    }

    public func asBinary() throws -> Data {
        if let binary = binary {
            return binary
        }
        throw Error.IncompatibleType
    }

    public func asArray() throws -> [InterchangeData] {
        if let array = array {
            return array
        }
        throw Error.IncompatibleType
    }

    public func asDictionary() throws -> [String: InterchangeData] {
        if let dictionary = dictionary {
            return dictionary
        }
        throw Error.IncompatibleType
    }

    public subscript(index: Int) -> InterchangeData? {
        set {
            switch self {
            case .Array(let array):
                var array = array
                if index > 0 && index < array.count {
                    if let interchangeData = newValue {
                        array[index] = interchangeData
                    } else {
                        array[index] = .Null
                    }
                    self = .Array(array)
                }
            default: break
            }
        }
        get {
            if let array = array where index > 0  && index < array.count {
                return array[index]
            }
            return nil
        }
    }

    public subscript(key: String) -> InterchangeData? {
        set {
            switch self {
            case .Dictionary(let dictionary):
                var dictionary = dictionary
                dictionary[key] = newValue
                self = .Dictionary(dictionary)
            default: break
            }
        }
        get {
            return dictionary?[key]
        }
    }
}

extension InterchangeData: Equatable {}

public func ==(lhs: InterchangeData, rhs: InterchangeData) -> Bool {
    switch lhs {
    case .Null:
        switch rhs {
        case .Null: return true
        default: return false
        }
    case .Boolean(let lhsValue):
        switch rhs {
        case .Boolean(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .Text(let lhsValue):
        switch rhs {
        case .Text(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .Binary(let lhsValue):
        switch rhs {
        case .Binary(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .Number(let lhsValue):
        switch rhs {
        case .Number(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .Array(let lhsValue):
        switch rhs {
        case .Array(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .Dictionary(let lhsValue):
        switch rhs {
        case .Dictionary(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    }
}

extension InterchangeData: NilLiteralConvertible {
    public init(nilLiteral value: Void) {
        self = .Null
    }
}

extension InterchangeData: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .Boolean(value)
    }
}

extension InterchangeData: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .Number(Double(value))
    }
}

extension InterchangeData: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .Number(Double(value))
    }
}

extension InterchangeData: StringLiteralConvertible {
    public init(unicodeScalarLiteral value: String) {
        self = .Text(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .Text(value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self = .Text(value)
    }
}

extension InterchangeData: StringInterpolationConvertible {
    public init(stringInterpolation strings: InterchangeData...) {
        var string = ""

        for s in strings {
            string += s.text!
        }

        self = .Text(String(string))
    }

    public init<T>(stringInterpolationSegment expr: T) {
        self = .Text(String(expr))
    }
}

extension InterchangeData: ArrayLiteralConvertible {
    public init(arrayLiteral elements: InterchangeData...) {
        self = .Array(elements)
    }
}

extension InterchangeData: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, InterchangeData)...) {
        var dictionary = [String: InterchangeData](minimumCapacity: elements.count)

        for pair in elements {
            dictionary[pair.0] = pair.1
        }

        self = .Dictionary(dictionary)
    }
}

extension InterchangeData: CustomStringConvertible {
    public var description: String {
        var indentLevel = 0

        func serialize(data: InterchangeData) -> String {
            switch data {
            case .Null: return "null"
            case .Boolean(let b): return b ? "true" : "false"
            case .Number(let n): return serializeNumber(n)
            case .Text(let s): return escape(s)
            case .Binary(let d): return escape(d.hexDescription)
            case .Array(let a): return serializeArray(a)
            case .Dictionary(let o): return serializeObject(o)
            }
        }

        func serializeNumber(n: Double) -> String {
            if n == Double(Int64(n)) {
                return Int64(n).description
            } else {
                return n.description
            }
        }

        func serializeArray(a: [InterchangeData]) -> String {
            var s = "["
            indentLevel += 1

            for i in 0 ..< a.count {
                s += "\n"
                s += indent()
                s += serialize(a[i])

                if i != (a.count - 1) {
                    s += ","
                }
            }

            indentLevel -= 1
            return s + "\n" + indent() + "]"
        }

        func serializeObject(o: [String: InterchangeData]) -> String {
            var s = "{"
            indentLevel += 1
            var i = 0

            for (key, value) in o {
                s += "\n"
                s += indent()
                s += "\(escape(key)): \(serialize(value))"

                if i != (o.count - 1) {
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

func escape(source: String) -> String {
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