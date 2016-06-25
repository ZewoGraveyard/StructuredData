import Reflection

extension C7.StructuredDataInitializable {
    
    init(structuredData: StructuredData) throws {
        let dictionary = try structuredData.asDictionary()
        self = try construct { property in
            guard let initializable = property.type as? C7.StructuredDataInitializable.Type else {
                throw StructuredDataError.notStructuredDataInitializable(property.type)
            }
            return try initializable.init(structuredData: dictionary[property.key] ?? .null)
        }
    }
    
}

extension Optional : C7.StructuredDataInitializable {
    
    public init(structuredData: StructuredData) throws {
        switch structuredData {
        case .null: self = .none
        default:
            guard let initializable = Wrapped.self as? C7.StructuredDataInitializable.Type else {
                throw StructuredDataError.notStructuredDataInitializable(Wrapped)
            }
            self = try initializable.init(structuredData: structuredData) as? Wrapped
        }
    }
    
}

extension Bool : C7.StructuredDataInitializable {
    
    public init(structuredData: StructuredData) throws {
        guard case .bool(let bool) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Bool.self, from: try structuredData.get().dynamicType)
        }
        self = bool
    }
    
}

extension Double : C7.StructuredDataInitializable {
    
    public init(structuredData: StructuredData) throws {
        guard case .double(let double) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Double.self, from: try structuredData.get().dynamicType)
        }
        self = double
    }
    
}

extension Int : C7.StructuredDataInitializable {
    
    public init(structuredData: StructuredData) throws {
        guard case .int(let int) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Int.self, from: try structuredData.get().dynamicType)
        }
        self = int
    }
    
}

extension String : C7.StructuredDataInitializable {
    
    public init(structuredData: StructuredData) throws {
        guard case .string(let string) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: String.self, from: try structuredData.get().dynamicType)
        }
        self = string
    }
    
}

extension Data : C7.StructuredDataInitializable {
    
    public init(structuredData: StructuredData) throws {
        guard case .data(let data) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Data.self, from: try structuredData.get().dynamicType)
        }
        self = data
    }
    
}

extension Array : C7.StructuredDataInitializable {
    
    public init(structuredData: StructuredData) throws {
        guard case .array(let array) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Array.self, from: try structuredData.get().dynamicType)
        }
        guard let initializable = Element.self as? C7.StructuredDataInitializable.Type else {
            throw StructuredDataError.notStructuredDataInitializable(Element.self)
        }
        self = try array.map { try initializable.init(structuredData: $0) as! Element }
    }
    
}

extension Dictionary : C7.StructuredDataInitializable {
    
    public init(structuredData: StructuredData) throws {
        guard case .dictionary(let dictionary) = structuredData else {
            throw StructuredDataError.cannotInitialize(type: Dictionary.self, from: try structuredData.get().dynamicType)
        }
        guard Key.self is String.Type else {
            throw StructuredDataError.notStructuredDataInitializable(self.dynamicType)
        }
        guard let initializable = Value.self as? C7.StructuredDataInitializable.Type else {
            throw StructuredDataError.notStructuredDataInitializable(Element)
        }
        self = try dictionary.reduce([:]) {
            var dictionary = $0
            dictionary[$1.key as! Key] = try initializable.init(structuredData: $1.value) as? Value
            return dictionary
        }
    }
    
}
