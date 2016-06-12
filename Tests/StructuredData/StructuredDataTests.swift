import XCTest
@testable import StructuredData

let boolData: StructuredData = .bool(true)
let intData: StructuredData = .int(1)
let doubleData: StructuredData = .double(1.5)
let stringData: StructuredData = .string("string")
let arrayData: StructuredData = .array([true, 1.5])
let dictData: StructuredData = .dictionary(["bool": false, "double": 1.5])


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
		XCTAssertEqual(StructuredData.infer(true), boolData)
		XCTAssertEqual(StructuredData.infer(1), intData)
		XCTAssertEqual(StructuredData.infer(1.5), doubleData)
		XCTAssertEqual(StructuredData.infer("string"), stringData)
		XCTAssertEqual(StructuredData.infer([true, 1.5]), arrayData)
		XCTAssertEqual(StructuredData.infer(["bool": false, "double": 1.5]), dictData)
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
		XCTAssertEqual(boolData.boolValue, true)
		XCTAssertEqual(intData.intValue, 1)
		XCTAssertEqual(intData.uintValue, 1)
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
		XCTAssertEqual(arrayData[0], .bool(true))
		XCTAssertEqual(arrayData[1], .double(1.5))
		XCTAssertEqual(boolData[0], nil)

		var array = arrayData
		array[0] = .string("string")
		array[1] = nil

		XCTAssertEqual(array[0], .string("string"))
		XCTAssertEqual(array[1], .null)
	}

	func testSubscriptByKey() {
		XCTAssertEqual(dictData["bool"], .infer(false))
		XCTAssertEqual(dictData["double"], .infer(1.5))

		var dict = dictData
		dict["string"] = .infer("string")
		dict["bool"] = .infer(true)

		XCTAssertEqual(dict["bool"], .infer(true))
		XCTAssertEqual(dict["string"], .infer("string"))
	}
}
