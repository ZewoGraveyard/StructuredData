import XCTest
@testable import StructuredData

class StructuredDataTests: XCTestCase {
	let array: [StructuredData] = [.from(true), .from(1)]
	let dict: [String: StructuredData] = ["bool": .from(false), "double": .from(1.5)]

	let boolData: StructuredData = .boolValue(true)
	let intData: StructuredData = .numberValue(1)
	let doubleData: StructuredData = .numberValue(1.5)
	let stringData: StructuredData = .stringValue("string")
	lazy var arrayData: StructuredData = .arrayValue(self.array)
	lazy var dictData: StructuredData = .dictionaryValue(self.dict)

	func testReality() {
		XCTAssert(2 + 2 == 4, "Something is severely wrong here.")
	}

	func testFrom() {
		XCTAssertEqual(StructuredData.from(true), boolData)
		XCTAssertEqual(StructuredData.from(1), intData)
		XCTAssertEqual(StructuredData.from(1.5), doubleData)
		XCTAssertEqual(StructuredData.from("string"), stringData)
		XCTAssertEqual(StructuredData.from(array), arrayData)
		XCTAssertEqual(StructuredData.from(dict), dictData)
	}

	func testCheckType() {
		XCTAssertTrue(boolData.isBool)
		XCTAssertTrue(intData.isNumber)
		XCTAssertTrue(doubleData.isNumber)
		XCTAssertTrue(stringData.isString)
		XCTAssertTrue(arrayData.isArray)
		XCTAssertTrue(dictData.isDictionary)

		XCTAssertFalse(boolData.isNumber)
		XCTAssertFalse(intData.isBool)
	}

	func testSubscriptByIndex() {
		XCTAssertEqual(arrayData[0], .boolValue(true))
		XCTAssertEqual(arrayData[1], .numberValue(1))
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

	func testGet() {
		let bool: Bool? = try? boolData.get()
		XCTAssertEqual(bool, true)

		let double: Double? = try? intData.get()
		XCTAssertEqual(double, 1)

		let int = try? intData.asInt()
		XCTAssertEqual(int, 1)
	}
}

extension StructuredDataTests {
    static var allTests: [(String, StructuredDataTests -> () throws -> Void)] {
        return [
           ("testReality", testReality),
        ]
    }
}
