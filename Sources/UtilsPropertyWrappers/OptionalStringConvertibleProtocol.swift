//
//  File.swift
//
//
//  Created by Home on 05/04/26.
//

import Foundation

public protocol OptionalStringConvertibleProtocol {
    associatedtype Value
    static func makeFromString(_ string: String, container: any SingleValueDecodingContainer) throws -> Value
    
    static func shouldContinue(after error: DecodingError, isString: Bool) -> Result<Value, Error>?
}

extension Optional: OptionalStringConvertibleProtocol where Wrapped: LosslessStringConvertible {
    public static func makeFromString(_ string: String, container: any SingleValueDecodingContainer) throws -> Self {
        Wrapped(string)
    }
    
    public static func shouldContinue(after error: DecodingError, isString: Bool) -> Result<Self, Error>? {
        switch error {
        case .typeMismatch:
            if isString {
                return nil // send continue
            } else {
                return .success(nil)
            }
        case .valueNotFound, .keyNotFound: return .success(nil)
        default: return .failure(error)
        }
    }
}

extension OptionalStringConvertibleProtocol where Value: LosslessStringConvertible, Value == Self {
    public static func makeFromString(_ string: String, container: any SingleValueDecodingContainer) throws -> Value {
        if let val = Value(string) {
            return val
        }
        
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Failed to initialize \(Value.self) from string '\(string)'"
        )
    }
    
    public static func shouldContinue(after error: DecodingError, isString: Bool) -> Result<Value, Error>? {
        switch error {
        case .typeMismatch where isString:
            return nil // send continue
        default: return .failure(error)
        }
    }
}

extension Bool : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension Character : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension Double : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension Float : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}
#if !os(macOS)
extension Float16 : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}
#endif

extension Float80 : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension Int : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension Int16 : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension Int32 : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension Int64 : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension Int8 : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension String : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension Substring : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension UInt : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension UInt16 : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension UInt32 : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension UInt64 : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension UInt8 : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

extension Unicode.Scalar : OptionalStringConvertibleProtocol {
    public typealias Value = Self
}

