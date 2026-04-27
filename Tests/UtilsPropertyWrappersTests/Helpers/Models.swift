//
//  File.swift
//  
//
//  Created by Home on 27/04/26.
//

@testable import UtilsPropertyWrappers

extension Encodable {
    func decodeTo<T: Decodable>(_ type: T.Type) throws -> T {
        try self.jsonEncoded().jsonDecoded(type.self)
    }
}

// MARK: - Encodable
struct EmptyEncodable: Encodable {}
struct NilEncodable: Encodable {
    @DecodedFromString var x: String? = nil
}

struct EncodingStringStruct: Encodable {
    @DecodedFromString var x: String
}

struct EncodingStruct: Encodable {
    @DecodedFromString var x: Int
}

// MARK: - Decodable
struct DecodingStruct: Decodable {
    @DecodedFromString var x: Int
}

struct DecodingDefaultStruct: Decodable {
    @DecodedFromString var x: Int = 777
}

struct DecodingOptionalStruct: Decodable {
    @DecodedFromString var x: Int?
}
