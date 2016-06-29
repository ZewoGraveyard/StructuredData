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

import Reflection

extension StructuredDataInitializable {
    public init(structuredData: StructuredData) throws {
        guard case .dictionary(let dictionary) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Self.self, from: try structuredData.get().dynamicType)
        }
        self = try construct { property in
            guard let initializable = property.type as? StructuredDataInitializable.Type else {
                throw StructuredDataError.notStructuredDataInitializable(property.type)
            }
            switch dictionary[property.key] ?? .null {
            case .null:
                guard let nilLiteralConvertible = property.type as? NilLiteralConvertible.Type else {
                    throw Reflection.Error.requiredValueMissing(key: property.key)
                }
                return nilLiteralConvertible.init(nilLiteral: ())
            case let x:
                return try initializable.init(structuredData: x)
            }
        }
    }
}

extension Optional : StructuredDataInitializable {
    public init(structuredData: StructuredData) throws {
        switch structuredData {
        case .null: self = .none
        default:
            guard let initializable = Wrapped.self as? StructuredDataInitializable.Type else {
                throw StructuredDataError.notStructuredDataInitializable(Wrapped.self)
            }
            self = try initializable.init(structuredData: structuredData) as? Wrapped
        }
    }
}

extension Bool : StructuredDataInitializable {
    public init(structuredData: StructuredData) throws {
        guard case .bool(let bool) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Bool.self, from: try structuredData.get().dynamicType)
        }
        self = bool
    }
}

extension Double : StructuredDataInitializable {
    public init(structuredData: StructuredData) throws {
        guard case .double(let double) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Double.self, from: try structuredData.get().dynamicType)
        }
        self = double
    }
}

extension Int : StructuredDataInitializable {
    public init(structuredData: StructuredData) throws {
        guard case .int(let int) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Int.self, from: try structuredData.get().dynamicType)
        }
        self = int
    }
}

extension String : StructuredDataInitializable {
    public init(structuredData: StructuredData) throws {
        guard case .string(let string) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: String.self, from: try structuredData.get().dynamicType)
        }
        self = string
    }
}

extension Data : StructuredDataInitializable {
    public init(structuredData: StructuredData) throws {
        guard case .data(let data) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Data.self, from: try structuredData.get().dynamicType)
        }
        self = data
    }
}

extension Array : StructuredDataInitializable {
    public init(structuredData: StructuredData) throws {
        guard case .array(let array) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Array.self, from: try structuredData.get().dynamicType)
        }
        guard let initializable = Element.self as? StructuredDataInitializable.Type else {
            throw StructuredDataError.notStructuredDataInitializable(Element.self)
        }
        var this = Array()
        this.reserveCapacity(array.count)
        for element in array {
            try this.append(initializable.init(structuredData: element) as! Element)
        }
        self = this
    }
}

public protocol StructuredDataDictionaryKeyInitializable {
    init(structuredDataDictionaryKey: String)
}

extension String: StructuredDataDictionaryKeyInitializable {
    public init(structuredDataDictionaryKey: String) {
        self = structuredDataDictionaryKey
    }
}

extension Dictionary : StructuredDataInitializable {
    public init(structuredData: StructuredData) throws {
        guard case .dictionary(let dictionary) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Dictionary.self, from: try structuredData.get().dynamicType)
        }
        guard let keyInitializable = Key.self as? StructuredDataDictionaryKeyInitializable.Type else {
            throw StructuredDataError.notStructuredDataDictionaryKeyInitializable(self.dynamicType)
        }
        guard let valueInitializable = Value.self as? StructuredDataInitializable.Type else {
            throw StructuredDataError.notStructuredDataInitializable(Element.self)
        }
        var this = Dictionary(minimumCapacity: dictionary.count)
        for (key, value) in dictionary {
            this[keyInitializable.init(structuredDataDictionaryKey: key) as! Key] = try valueInitializable.init(structuredData: value) as? Value
        }
        self = this
    }
}
