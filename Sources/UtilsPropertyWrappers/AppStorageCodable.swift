//
//  File.swift
//  
//
//  Created by Home on 10/01/26.
//

import Foundation

//    @AppStorage is some how updating in directly view and from @ObsevableObject
//  if two different place are using same key both variable should be in sink

// will not update UI if used from @ObsevableObject
// need to test for directly in View
// might need to use Combine since @Publised and @ObsevableObject are in Combine framework
@propertyWrapper
public struct AppStorageCodable<Value: Codable> {
    let key: String
    var value: Value
    
    public init(wrappedValue: Value, key: String) {
        self.key = key
        
        let value = try? UserDefaults.standard.data(forKey: key)?.jsonDecoded(Value.self)
        self.value = value ?? wrappedValue
    }
    
    public var wrappedValue: Value {
        get {
            value
        } set {
            if let data = try? newValue.jsonEncoded() {
                value = newValue
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
}

extension Data {
    func jsonDecoded<D: Decodable>(_ type: D.Type, decoder: JSONDecoder = JSONDecoder()) throws -> D {
        try decoder.decode(type, from: self)
    }
}

extension Encodable {
    func jsonEncoded(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }
}
