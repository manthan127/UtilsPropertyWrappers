//
//  File.swift
//  
//
//  Created by Home on 16/04/26.
//

import Foundation

extension KeyedDecodingContainer {
    func decode<T>(
        _ type: DecodedFromString<T?>.Type,
        forKey key: Key
    ) throws -> DecodedFromString<T?> where T: Decodable {
        try decodeIfPresent(type, forKey: key) ?? DecodedFromString(wrappedValue: nil)
    }
}
