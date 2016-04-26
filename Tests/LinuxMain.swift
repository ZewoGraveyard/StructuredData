#if os(Linux)

import XCTest
@testable import StructuredDataTestSuite

XCTMain([
    testCase(StructuredDataTests.allTests)
])

#endif
