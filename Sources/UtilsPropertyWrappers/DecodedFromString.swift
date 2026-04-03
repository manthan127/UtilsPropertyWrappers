//
//  DecodedFromString.swift
//  Utils
//
//  Created by Home on 17/04/25.
//

import Foundation

//extension Optional: @retroactive CustomStringConvertible where Wrapped: LosslessStringConvertible {
//    public var description: String {
//        self?.description ?? "nil"
//    }
//}
//extension Optional: @retroactive LosslessStringConvertible where Wrapped: LosslessStringConvertible {
//    public init?(_ description: String) {
//        self = Wrapped(description)
//    }
//}

//TODO: allow optional values
@propertyWrapper public struct DecodedFromString<Value: LosslessStringConvertible> {
    private var value: Value
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: Value {
        get {
            value
        }  set {
            value = newValue
        }
    }
}

extension DecodedFromString: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        if let value = try Self.decodedValue(decoder: decoder, allowsNil: false) {
            self.value = value
            return
        }
        
        throw DecodingError.typeMismatch(
            Value.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected \(Value.self) or String convertible to \(Value.self), but found incompatible value"
            )
        )
    }
    
    public init(from decoder: Decoder) throws where Value: ExpressibleByNilLiteral {
        value = try Self.decodedValue(decoder: decoder, allowsNil: true) ?? nil
    }
    
    private static func decodedValue(decoder: Decoder, allowsNil: Bool) throws -> Value? {
        func shouldContinue(after error: DecodingError) -> Bool {
            switch error {
            case .typeMismatch(let type, _): type == String.self
            case .valueNotFound: allowsNil
            default: false
            }
        }
        
        let container = try decoder.singleValueContainer()
        
        do {
            let stringValue = try container.decode(String.self)
            if let parsedValue = Value(stringValue) {
                return parsedValue
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Failed to initialize \(Value.self) from string '\(stringValue)'"
            )
        } catch let error as DecodingError {
            if !shouldContinue(after: error) {
                throw error
            }
        } catch {
            throw error
        }
        
        do {
            return try container.decode(Value.self)
        } catch let error as DecodingError {
            if !shouldContinue(after: error) {
                throw error
            }
        } catch {
            throw error
        }
        return nil
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


// struct Test2: Encodable {
//     @DecodedFromString var x: Int
// }

// struct Test: Decodable {
//     @DecodedFromString var x: Int
// }

// do {
//     let test = try Test2(x: 54).jsonEncoded().jsonDecoded(Test.self)
//     print(test.x)
// } catch {
//     print(error)
// }
