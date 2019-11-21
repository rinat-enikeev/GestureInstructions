import XCTest
@testable import GestureInstructions

final class GestureInstructionsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(GestureInstructions().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
