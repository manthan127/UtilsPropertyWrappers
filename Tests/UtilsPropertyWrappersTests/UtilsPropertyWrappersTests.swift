import XCTest

final class UtilsPropertyWrappersTests: XCTestCase {
    func testBaseCase() throws {
        let test = try EncodingStruct(x: 54).decodeTo(DecodingStruct.self)
        XCTAssertEqual(test.x, 54)
    }
    
    func testFromString() throws {
        let test = try EncodingStringStruct(x: "54").decodeTo(DecodingStruct.self)
        XCTAssertEqual(test.x, 54)
    }
    
    func testFromInvalidString() {
        XCTAssertThrowsError(
            try EncodingStringStruct(x: "invalid input").decodeTo(DecodingStruct.self)
        )
    }
    
    func testEmpty() {
        XCTAssertThrowsError(
            try EmptyEncodable().decodeTo(DecodingStruct.self)
        )
    }
    
    func testNilEncoded() throws {
        XCTAssertThrowsError(
            try NilEncodable().decodeTo(DecodingStruct.self)
        )
    }
    
    // TODO: - this is the only case not working
    func testDefaultVal() throws {
        let test = try EmptyEncodable().decodeTo(DecodingDefaultStruct.self)
        XCTAssertEqual(test.x, 777)
    }
}
 
extension UtilsPropertyWrappersTests {
    func testBaseCaseOptional() throws {
        let test = try EncodingStruct(x: 54).decodeTo(DecodingOptionalStruct.self)
        XCTAssertEqual(test.x, 54)
    }
    
    func testFromStringToOptional() throws {
        let test = try EncodingStringStruct(x: "54").decodeTo(DecodingOptionalStruct.self)
        XCTAssertEqual(test.x, 54)
    }
    
    func testFromInvalidStringOptional() throws {
        let test = try EncodingStringStruct(x: "should be nil").decodeTo(DecodingOptionalStruct.self)
        XCTAssertNil(test.x)
    }
    
    func testEmptyOptional() throws {
        let test = try EmptyEncodable().decodeTo(DecodingOptionalStruct.self)
        XCTAssertNil(test.x)
    }
    
    func testNilOptional() throws {
        let test = try NilEncodable().decodeTo(DecodingOptionalStruct.self)
        XCTAssertNil(test.x)
    }
}
