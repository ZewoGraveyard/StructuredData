#if os(Linux)

import XCTest
@testable import StructuredDataTests

XCTMain([
    testCase(StructuredDataTests.allTests),
])

#endif
