import XCTest
@testable import UtilsPropertyWrappers

struct EncodingStringStruct: Encodable {
    @DecodedFromString var x: String
}

struct EncodingStruct: Encodable {
    @DecodedFromString var x: Int
}

struct DecodingStruct: Decodable {
    @DecodedFromString var x: Int
}

struct DecodingOptionalStruct: Decodable {
    @DecodedFromString var x: Int?
}

fileprivate extension Encodable {
    func decodeTo<T: Decodable>(_ type: T.Type) throws -> T {
        self.jsonEncoded().jsonDecoded(type.self)
    }
}

final class UtilsPropertyWrappersTests: XCTestCase {
    func testBaseCase() throws {
        let test:  = try EncodingStruct(x: 54).decodeTo(DecodingStruct.self)
        
        XCTAssertEqual(test.x, 54)
    }
    
    func testFromString() throws {
        let test = try EncodingStringStruct(x: "54").decodeTo(DecodingStruct.self)
        XCTAssertEqual(test.x, 54)
    }
    
    func testFromStringInvalid() {
        XCTAssertThrowsError(
            try EncodingStringStruct(x: "invalid input").decodeTo(DecodingStruct.self)
        ) { error in
            // Optional: You can inspect the error here
            print("Caught expected error: \(error)")
        }
    }
    
    func testFromStringToOptional() throws {
        let test = try EncodingStringStruct(x: "54").decodeTo(DecodingStruct.self)
        XCTAssertEqual(test.x, 54)
    }
    
    // should invalid string throw error or just give nil ??
    func testFromStringToOptionalWrong() throws {
        let test = try EncodingStringStruct(x: "should be nil").decodeTo(DecodingOptionalStruct.self)
        XCTAssertEqual(test.x, nil)
    }
}
