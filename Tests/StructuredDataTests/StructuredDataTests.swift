import XCTest
@testable import StructuredData

let boolData: StructuredData = true
let intData: StructuredData = 1
let doubleData: StructuredData = 1.5
let stringData: StructuredData = "string"
let arrayData: StructuredData = [true, 1.5]
let dictData: StructuredData = ["bool": false, "double": 1.5]
let nullData: StructuredData = nil

class StructuredDataTests: XCTestCase {
	func testFrom() {
		XCTAssertEqual(StructuredData.infer(true), boolData)
		XCTAssertEqual(StructuredData.infer(1), intData)
		XCTAssertEqual(StructuredData.infer(1.5), doubleData)
		XCTAssertEqual(StructuredData.infer("string"), stringData)
		XCTAssertEqual(StructuredData.infer([true, 1.5]), arrayData)
		XCTAssertEqual(StructuredData.infer(["bool": false, "double": 1.5]), dictData)
	}

    func testCheckType() {
		XCTAssertTrue(boolData.isBool)
		XCTAssertTrue(intData.isInt)
        XCTAssertTrue(doubleData.isDouble)
        XCTAssertTrue(stringData.isString)
        XCTAssertTrue(arrayData.isArray)
        XCTAssertTrue(dictData.isDictionary)

        XCTAssertFalse(boolData.isDouble)
        XCTAssertFalse(doubleData.isBool)
	}

	func testRetrieveRawValue() {
		XCTAssertEqual(boolData.boolValue, true)
		XCTAssertEqual(intData.intValue, 1)
		XCTAssertEqual(doubleData.doubleValue, 1.5)
		XCTAssertEqual(stringData.stringValue, "string")

		let narray = arrayData.arrayValue
		XCTAssertNotNil(narray)
		if let narray = narray {
			XCTAssertEqual(narray, [true, 1.5])
		}

		let ndict = dictData.dictionaryValue
		XCTAssertNotNil(ndict)
		if let ndict = ndict {
			XCTAssertEqual(ndict, ["bool": false, "double": 1.5])
		}

		XCTAssertNil(boolData.intValue)
		XCTAssertNil(intData.boolValue)
		XCTAssertNil(stringData.doubleValue)
    }

	func testAs() {
		XCTAssertEqual(try? boolData.asBool(), true)
        XCTAssertNotEqual(try? doubleData.asInt(), 1)
		XCTAssertEqual(try? doubleData.asDouble(), 1.5)
		XCTAssertEqual(try? stringData.asString(), "string")
        let str = "str"
        let ing = "ing"
        XCTAssertEqual(try? stringData.asString(), "\(str)\(ing)")

		let array = try? arrayData.asArray()
		XCTAssertNotNil(array)
		if let array = array {
			XCTAssertEqual(array, [true, 1.5])
		}

		let dict = try? dictData.asDictionary()
		XCTAssertNotNil(dict)
		if let dict = dict {
			XCTAssertEqual(dict, ["bool": false, "double": 1.5])
		}

		XCTAssertNil(try? boolData.asInt())
		XCTAssertNil(try? doubleData.asBool())
		XCTAssertNil(try? stringData.asDouble())
	}

    func testAsConverting() {
        XCTAssertEqual(try? boolData.asInt(converting: true), 1)
        XCTAssertEqual(try? doubleData.asInt(converting: true), 1)
        XCTAssertEqual(try? intData.asDouble(converting: true), 1.0)
        XCTAssertEqual(try? StructuredData("True").asBool(converting: true), true)

        let narray = try? nullData.asArray(converting: true)
        XCTAssertNotNil(narray)
        if let narray = narray {
            XCTAssertEqual(narray, [])
        }

        XCTAssertNil(try? stringData.asInt(converting: true))
        XCTAssertNil(try? StructuredData.int(2).asBool(converting: true))
        XCTAssertNil(try? arrayData.asDictionary(converting: true))
    }

	func testGet() {
		let bool: Bool? = try? boolData.get()
		XCTAssertEqual(bool, true)

		let double: Double? = try? doubleData.get()
		XCTAssertEqual(double, 1.5)

		let int: Int? = try? intData.get()
		XCTAssertEqual(int, 1)

        let nint: Int? = try? doubleData.get()
		XCTAssertNil(nint)

		let uint: UInt? = try? doubleData.get()
		XCTAssertNil(uint)

		let string: String? = try? stringData.get()
		XCTAssertEqual(string, "string")

		let array: [StructuredData]? = try? arrayData.get()
		XCTAssertNotNil(array)

		let dict: [String: StructuredData]? = try? dictData.get()
		XCTAssertNotNil(dict)
	}

	func testSubscriptByIndex() {
		XCTAssertEqual(arrayData[0], true)
		XCTAssertEqual(arrayData[1], 1.5)
		XCTAssertEqual(boolData[0], nil)

		var array = arrayData
		array[0] = "string"
		array[1] = nil

		XCTAssertEqual(array[0], "string")
		XCTAssertEqual(array[1], .null)
	}

	func testSubscriptByKey() {
		XCTAssertEqual(dictData["bool"], false)
		XCTAssertEqual(dictData["double"], 1.5)

		var dict = dictData
		dict["string"] = "string"
		dict["bool"] = true

		XCTAssertEqual(dict["bool"], true)
		XCTAssertEqual(dict["string"], "string")
	}

    func testInfer() {
        let optionalBool: Bool? = nil
        let optionalInt: Int? = nil
        let optionalDouble: Double? = nil
        let optionalString: String? = nil
        let optionalData: C7.Data? = nil
        let optionalArray: [String]? = nil
        let optionalArrayOfOptional: [String?]? = nil
        let optionalDictionary: [String: String]? = nil
        let optionalDictionaryOfOptional: [String: String?]? = nil

        let bool: Bool = true
        let int: Int = 1
        let double: Double = 1.5
        let string: String = "string"
        let data: C7.Data = [0]
        let array: [String] = ["foo"]
        let arrayOfOptional: [String?] = [nil]
        let dictionary: [String: String] = ["foo": "bar"]
        let dictionaryOfOptional: [String: String?] = ["foo": nil]

        let structuredData: StructuredData = [
             "optionalBool": .infer(optionalBool),
             "optionalInt": .infer(optionalInt),
             "optionalDouble": .infer(optionalDouble),
             "optionalString": .infer(optionalString),
             "optionalData": .infer(optionalData),
             "optionalArray": .infer(optionalArray),
             "optionalArrayOfOptional": .infer(optionalArrayOfOptional),
             "optionalDictionary": .infer(optionalDictionary),
             "optionalDictionaryOfOptional": .infer(optionalDictionaryOfOptional),

            "bool": .infer(bool),
            "int": .infer(int),
            "double": .infer(double),
            "string": .infer(string),
            "data": .infer(data),
            "array": .infer(array),
            "arrayOfOptional": .infer(arrayOfOptional),
            "dictionary": .infer(dictionary),
            "dictionaryOfOptional": .infer(dictionaryOfOptional),
        ]

        guard let dict = try? structuredData.asDictionary() else {
            return XCTFail()
        }

        XCTAssertEqual(dict["optionalBool"], .null)
        XCTAssertEqual(dict["optionalInt"], .null)
        XCTAssertEqual(dict["optionalDouble"], .null)
        XCTAssertEqual(dict["optionalString"], .null)
        XCTAssertEqual(dict["optionalData"], .null)
        XCTAssertEqual(dict["optionalArray"], .null)
        XCTAssertEqual(dict["optionalArrayOfOptional"], .null)
        XCTAssertEqual(dict["optionalDictionary"], .null)
        XCTAssertEqual(dict["optionalDictionaryOfOptional"], .null)

        XCTAssertEqual(dict["bool"], .bool(bool))
        XCTAssertEqual(dict["int"], .int(int))
        XCTAssertEqual(dict["double"], .double(double))
        XCTAssertEqual(dict["string"], .string(string))
        XCTAssertEqual(dict["data"], .data(data))
        XCTAssertEqual(dict["array"], .array([.string("foo")]))
        XCTAssertEqual(dict["arrayOfOptional"], .array([.null]))
        XCTAssertEqual(dict["dictionary"], .dictionary(["foo": .string("bar")]))
        XCTAssertEqual(dict["dictionaryOfOptional"], .dictionary(["foo": .null]))
    }
}

extension StructuredDataTests {
    static var allTests: [(String, (StructuredDataTests) -> () throws -> Void)] {
        return [
           ("testFrom", testFrom),
           ("testCheckType", testCheckType),
           ("testRetrieveRawValue", testRetrieveRawValue),
           ("testAs", testAs),
           ("testAsConverting", testAsConverting),
           ("testGet", testGet),
           ("testSubscriptByIndex", testSubscriptByIndex),
           ("testSubscriptByKey", testSubscriptByKey),
           ("testInfer", testInfer),
        ]
    }
}
