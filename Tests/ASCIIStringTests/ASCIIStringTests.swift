@testable import ASCIIString
import XCTest

final class ASCIIStringTests: XCTestCase {
	func testFirstSlice_single() {
		let slice = ASCIIString("a6bc").firstSlice(matching: \.isNumber)
		XCTAssertEqual(slice?.substring, "6")
		XCTAssertEqual(slice?.asciiRange, 1..<2)
	}

	func testFirstSlice_ignoresOthers() {
		let slice = ASCIIString("123abc456").firstSlice(matching: \.isNumber)
		XCTAssertEqual(slice?.substring, "123")
		XCTAssertEqual(slice?.asciiRange, 0..<3)
	}

	func testFirstSlice_beginning() {
		let slice = ASCIIString("123abc").firstSlice(matching: \.isNumber)
		XCTAssertEqual(slice?.substring, "123")
		XCTAssertEqual(slice?.asciiRange, 0..<3)
	}

	func testFirstSlice_middle() {
		let slice = ASCIIString("a123bc").firstSlice(matching: \.isNumber)
		XCTAssertEqual(slice?.substring, "123")
		XCTAssertEqual(slice?.asciiRange, 1..<4)
	}

	func testFirstSlice_end() {
		let src = "abc123"
		let slice = ASCIIString(src).firstSlice(matching: \.isNumber)
		XCTAssertEqual(slice?.substring, "123")
		XCTAssertEqual(slice?.asciiRange, 3..<6)
		XCTAssertEqual(slice?.rawRange, src.index(src.startIndex, offsetBy: 3)..<src.endIndex)
	}

	func testFirstSlice_substring() {
		let src = "abc123"
		let slice = ASCIIString(src.dropFirst()).firstSlice(matching: \.isNumber)
		XCTAssertEqual(slice?.substring, "123")
		XCTAssertEqual(slice?.asciiRange, 3..<6)
		XCTAssertEqual(slice?.rawRange, src.index(src.startIndex, offsetBy: 3)..<src.endIndex)
	}

	func testAllSlices() {
		let slices = ASCIIString("abc123def456ghi").allSlices(matching: \.isNumber)
		XCTAssertEqual(slices.map(\.substring), ["123", "456"])
		XCTAssertEqual(slices.map(\.asciiRange), [3..<6, 9..<12])
	}
}
