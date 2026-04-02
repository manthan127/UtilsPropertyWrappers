//
//  File.swift
//  
//
//  Created by Home on 10/01/26.
//

import Foundation
import Combine

//    @AppStorage is some how updating in directly view and from @ObsevableObject

// will not update UI if used from @ObsevableObject
// might need to use Combine since @Publised and @ObsevableObject are in Combine framework
@propertyWrapper
public struct AppStorageCodable<Value: Codable>: DynamicProperty {
    @StateObject private var storage: CodableStorage<Value>
    
    public init(wrappedValue: Value, _ key: String) {
        _storage = StateObject(
            wrappedValue: CodableStorage(key: key, defaultValue: wrappedValue)
        )
    }
    
    public var wrappedValue: Value {
        get { storage.value }
        nonmutating set { storage.set(newValue) }
    }
    
    public var projectedValue: Binding<Value> {
        .init { storage.value } set: { storage.set($0) }
    }
}

private final class CodableStorage<Value: Codable>: ObservableObject {
    @Published var value: Value
    
    private let key: String
    private let store: UserDefaults
    
    init(key: String, defaultValue: Value, store: UserDefaults = .standard) {
        self.key = key
        self.store = store
        
        if let data = store.data(forKey: key),
           let decoded = try? data.jsonDecoded(Value.self) {
            self.value = decoded
        } else {
            self.value = defaultValue
        }
        // Might be issue when model is very big and there are to many observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sync),
            name: UserDefaults.didChangeNotification,
            object: store
        )
    }
    @objc private func sync() {
        if let data = store.data(forKey: key),
           let decoded = try? data.jsonDecoded(Value.self) {
            // TODO: only update value if value at the key is changed
            // TODO: do not change if value is not changed
            value = decoded
        }
    }
    
    func set(_ newValue: Value) {
        value = newValue
        if let data = try? newValue.jsonEncoded() {
            store.set(data, forKey: key)
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
