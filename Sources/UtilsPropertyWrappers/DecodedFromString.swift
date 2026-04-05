//
//  DecodedFromString.swift
//  Utils
//
//  Created by Home on 17/04/25.
//

import Foundation

//TODO: allow optional values

/// A property wrapper that allows decoding values from strings when an API returns numeric or boolean values as strings instead of their native types.
///
/// This wrapper supports types conforming to [`LosslessStringConvertible`](https://developer.apple.com/documentation/swift/losslessstringconvertible), such as `Int`, `Double`, `Bool`, `String`, and their optional variants.
///
/// Example:
/// ```swift
/// struct ApiResponse: Decodable {
///     @DecodedFromString var id: Int
///     @DecodedFromString var price: Double?
/// }
/// ```
@propertyWrapper public struct DecodedFromString<Value: OptionalStringConvertibleProtocol> {
    private var value: Value
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: Value {
        get { value }
        set { value = newValue }
    }
}

extension DecodedFromString: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            let stringValue = try container.decode(String.self)
            self.value = try Value.makeFromString(stringValue, container: container) as! Value
            return
        } catch let error as DecodingError {
            if let val = Value.shouldContinue(after: error, isString: true) {
                switch val {
                case .success(let success):
                    self.value = success as! Value
                    return
                case .failure:
                    throw error
                }
            }
        }
        
        do {
            self.value = try container.decode(Value.self)
        } catch let error as DecodingError {
            if let val = Value.shouldContinue(after: error, isString: false) {
                switch val {
                case .success(let success):
                    self.value = success as! Value
                    return
                case .failure:
                    throw error
                }
            }
            throw error
        }
//            self.value =
            //            if !Value.shouldContinue(after: error, isString: false) {
            //                throw error
            //            }
        
//        throw DecodingError.typeMismatch(
//            Value.self,
//            DecodingError.Context(
//                codingPath: decoder.codingPath,
//                debugDescription: "Expected \(Value.self) or String convertible to \(Value.self), but found incompatible value"
//            )
//        )
    }
}

extension DecodedFromString: Encodable where Value: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

extension DecodedFromString: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

extension DecodedFromString: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
    }
}
