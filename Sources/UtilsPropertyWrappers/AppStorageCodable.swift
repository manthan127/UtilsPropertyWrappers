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
// might need to use Combine since @Publised and @ObsevableObject are in Combine framework
@propertyWrapper
public struct AppStorageCodable<Value: Codable>: DynamicProperty {
    let key: String
    @State private var value: Value
    private let store: UserDefaults
    
    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) {
        self.key = key
        self.store = store ?? UserDefaults.standard
        let value = try? self.store.data(forKey: key)?.jsonDecoded(Value.self)
        self._value = .init(wrappedValue: value ?? wrappedValue)
    }
    
    public var wrappedValue: Value {
        get {
            value
        } nonmutating set {
            if let data = try? newValue.jsonEncoded() {
                value = newValue
                store.set(data, forKey: key)
            }
        }
    }
    
    public var projectedValue: Binding<Value> {
        .init { wrappedValue } set: { wrappedValue = $0 }
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
