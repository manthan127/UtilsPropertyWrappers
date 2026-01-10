//
//  DecodedFromString.swift
//  Utils
//
//  Created by Home on 17/04/25.
//

import Foundation

@propertyWrapper public struct DecodedFromString<Value: LosslessStringConvertible> {
    private var value: Value?
    
    public init(wrappedValue: Value?) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: Value? {
        get {
            value
        }  set {
            value = newValue
        }
    }
}

extension DecodedFromString: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self),
           let parsedValue = Value(stringValue) {
            self.value = parsedValue
        } else if let directValue = try? container.decode(Value.self) {
            self.value = directValue
        } else {
            self.value = nil
        }
    }
}

extension DecodedFromString: Encodable where Value: Encodable { }


//struct Example: LosslessStringConvertible, Decodable {
//    init?(_ description: String) {
//        if let x =  try? description.decode(to: Self.self) {
//            self = x
//        } else {
//            return nil
//        }
//    }
//    
//    var description: String
//}
