import XCTest
@testable import StructuredData

let boolData: StructuredData = .boolValue(true)
let intData: StructuredData = .integerValue(1)
let doubleData: StructuredData = .doubleValue(1.5)
let stringData: StructuredData = .stringValue("string")
let arrayData: StructuredData = .arrayValue([true, 1.5])
let dictData: StructuredData = .dictionaryValue(["bool": false, "double": 1.5])


class StructuredDataTests: XCTestCase {

	static var allTests: [(String, (StructuredDataTests) -> () throws -> Void)] {
        return [
           ("testFrom", testFrom),
           ("testCheckType", testCheckType),
           ("testRetrieveRawValue", testRetrieveRawValue),
           ("testGet", testGet),
           ("testAs", testAs),
           ("testSubscriptByIndex", testSubscriptByIndex),
           ("testSubscriptByKey", testSubscriptByKey),
        ]
    }

	func testFrom() {
		XCTAssertEqual(StructuredData.from(true), boolData)
		XCTAssertEqual(StructuredData.from(1), intData)
		XCTAssertEqual(StructuredData.from(1.5), doubleData)
		XCTAssertEqual(StructuredData.from("string"), stringData)
		XCTAssertEqual(StructuredData.from([true, 1.5]), arrayData)
		XCTAssertEqual(StructuredData.from(["bool": false, "double": 1.5]), dictData)
	}

	func testCheckType() {
		XCTAssertTrue(boolData.isBool)
		XCTAssertTrue(intData.isInteger)
		XCTAssertTrue(doubleData.isDouble)
		XCTAssertTrue(stringData.isString)
		XCTAssertTrue(arrayData.isArray)
		XCTAssertTrue(dictData.isDictionary)

		XCTAssertFalse(boolData.isInteger)
		XCTAssertFalse(intData.isBool)
	}

	func testRetrieveRawValue() {
		XCTAssertEqual(boolData.bool, true)
		XCTAssertEqual(intData.int, 1)
		XCTAssertEqual(intData.uint, 1)
		XCTAssertEqual(doubleData.double, 1.5)
		XCTAssertEqual(stringData.string, "string")

		let narray = arrayData.array
		XCTAssertNotNil(narray)
		if let narray = narray {
			XCTAssertEqual(narray, [true, 1.5])
		}

		let ndict = dictData.dictionary
		XCTAssertNotNil(ndict)
		if let ndict = ndict {
			XCTAssertEqual(ndict, ["bool": false, "double": 1.5])
		}

		XCTAssertNil(boolData.int)
		XCTAssertNil(intData.bool)
		XCTAssertNil(stringData.double)
	}

	func testGet() {
		let bool: Bool? = try? boolData.get()
		XCTAssertEqual(bool, true)

		let double: Double? = try? doubleData.get()
		XCTAssertEqual(double, 1.5)

		let int: Int? = try? intData.get()
		XCTAssertEqual(int, 1)

		let uint: UInt? = try? intData.get()
		XCTAssertNil(uint)

		let string: String? = try? stringData.get()
		XCTAssertEqual(string, "string")

		let array: [StructuredData]? = try? arrayData.get()
		XCTAssertNotNil(array)

		let dict: [String: StructuredData]? = try? dictData.get()
		XCTAssertNotNil(dict)
	}

	func testAs() {
		XCTAssertEqual(try? boolData.asBool(), true)
		XCTAssertEqual(try? intData.asInt(), 1)
		XCTAssertEqual(try? intData.asUInt(), 1)
		XCTAssertEqual(try? doubleData.asDouble(), 1.5)
		XCTAssertEqual(try? stringData.asString(), "string")

		let narray = try? arrayData.asArray()
		XCTAssertNotNil(narray)
		if let narray = narray {
			XCTAssertEqual(narray, [true, 1.5])
		}

		let ndict = try? dictData.asDictionary()
		XCTAssertNotNil(ndict)
		if let ndict = ndict {
			XCTAssertEqual(ndict, ["bool": false, "double": 1.5])
		}
		
		XCTAssertNil(try? boolData.asInt())
		XCTAssertNil(try? intData.asBool())
		XCTAssertNil(try? stringData.asDouble())
	}

	func testSubscriptByIndex() {
		XCTAssertEqual(arrayData[0], .boolValue(true))
		XCTAssertEqual(arrayData[1], .doubleValue(1.5))
		XCTAssertEqual(boolData[0], nil)

		var array = arrayData
		array[0] = .stringValue("string")
		array[1] = nil

		XCTAssertEqual(array[0], .stringValue("string"))
		XCTAssertEqual(array[1], .nullValue)
	}

	func testSubscriptByKey() {
		XCTAssertEqual(dictData["bool"], .from(false))
		XCTAssertEqual(dictData["double"], .from(1.5))

		var dict = dictData
		dict["string"] = .from("string")
		dict["bool"] = .from(true)

		XCTAssertEqual(dict["bool"], .from(true))
		XCTAssertEqual(dict["string"], .from("string"))
	}
}
