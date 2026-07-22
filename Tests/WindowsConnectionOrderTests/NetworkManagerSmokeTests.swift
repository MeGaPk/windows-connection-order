import XCTest

final class NetworkManagerSmokeTests: XCTestCase {
    func testUppercasingString() {
        XCTAssertEqual("swift pipeline".uppercased(), "SWIFT PIPELINE")
    }

    func testSetContainsElementAfterInsert() {
        var seen = Set<Int>()
        seen.insert(1)

        XCTAssertTrue(seen.contains(1))
        XCTAssertEqual(seen.count, 1)
    }
}