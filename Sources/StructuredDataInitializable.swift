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
            return try initializable.init(structuredData: dictionary[property.key] ?? .null)
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
        self = try array.map { try initializable.init(structuredData: $0) as! Element }
    }
}

extension Dictionary : StructuredDataInitializable {
    public init(structuredData: StructuredData) throws {
        guard case .dictionary(let dictionary) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Dictionary.self, from: try structuredData.get().dynamicType)
        }
        guard Key.self is String.Type else {
            throw StructuredDataError.notStructuredDataInitializable(self.dynamicType)
        }
        guard let initializable = Value.self as? StructuredDataInitializable.Type else {
            throw StructuredDataError.notStructuredDataInitializable(Element.self)
        }
        self = try dictionary.reduce([:]) {
            var dictionary = $0
            dictionary[$1.key as! Key] = try initializable.init(structuredData: $1.value) as? Value
            return dictionary
        }
    }
}
