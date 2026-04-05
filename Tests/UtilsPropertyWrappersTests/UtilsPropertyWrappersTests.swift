import XCTest
@testable import UtilsPropertyWrappers

struct EmptyEncodable: Encodable {
    var y: Int = 5
}

struct EncodingStringStruct: Encodable {
    @DecodedFromString var x: String
}

struct EncodingStruct: Encodable {
    @DecodedFromString var x: Int
}

struct DecodingStruct: Decodable {
    @DecodedFromString 
    var x: Int
}

struct DecodingOptionalStruct: Decodable {
    @DecodedFromString 
    var x: Int?
}

fileprivate extension Encodable {
    func decodeTo<T: Decodable>(_ type: T.Type) throws -> T {
        try self.jsonEncoded().jsonDecoded(type.self)
    }
}

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
        XCTAssertEqual(test.x, nil)
    }
    
    // this is failing and throwing error
    func testEmptyOptional() throws {
        let test = try EmptyEncodable().decodeTo(DecodingOptionalStruct.self)
        XCTAssertEqual(test.x, nil)
    }
}
