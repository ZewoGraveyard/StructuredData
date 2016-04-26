import XCTest
@testable import StructuredData

class StructuredDataTests: XCTestCase {
	func testReality() {
		XCTAssert(2 + 2 == 4, "Something is severely wrong here.")
	}
}

extension StructuredDataTests {
    static var allTests: [(String, StructuredDataTests -> () throws -> Void)] {
        return [
           ("testReality", testReality),
        ]
    }
}
