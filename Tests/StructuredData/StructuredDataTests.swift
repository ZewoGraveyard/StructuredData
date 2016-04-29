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

	func testAsWithoutConverting() {
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
}

extension StructuredDataTests {
    static var allTests: [(String, (StructuredDataTests) -> () throws -> Void)] {
        return [
           ("testCheckType", testCheckType),
           ("testAsWithoutConverting", testAsWithoutConverting),
           ("testAsConverting", testAsConverting),
           ("testGet", testGet),
           ("testSubscriptByIndex", testSubscriptByIndex),
           ("testSubscriptByKey", testSubscriptByKey),
        ]
    }
}
