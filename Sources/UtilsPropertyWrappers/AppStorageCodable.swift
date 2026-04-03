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
    
    public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) {
        _storage = StateObject(
            wrappedValue: CodableStorage(key: key, defaultValue: wrappedValue, store: store ?? .standard)
        )
    }
    
    public init(_ key: String, store: UserDefaults? = nil) where Value: ExpressibleByNilLiteral {
        _storage = StateObject(wrappedValue: CodableStorage(key: key, store: store ?? .standard))
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
    
    init(key: String, defaultValue: Value, store: UserDefaults) {
        self.key = key
        self.store = store
        self.value = CodableStorage.decodeValue(key: key, store: store) ?? defaultValue
        
        startObserver()
    }
    
    init(key: String, store: UserDefaults) where Value: ExpressibleByNilLiteral {
        self.key = key
        self.store = store
        self.value = CodableStorage.decodeValue(key: key, store: store) ?? nil
        
        startObserver()
    }
    
    func set(_ newValue: Value) {
        value = newValue
        if let data = try? newValue.jsonEncoded() {
            store.set(data, forKey: key)
        }
    }
    // TODO: check for UserDefaults other than UserDefaults.standard
    // Might be issue when model is very big and there are to many observers
    func startObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sync),
            name: UserDefaults.didChangeNotification,
            object: store
        )
    }
    
    @objc private func sync() {
        if let decoded = CodableStorage.decodeValue(key: key, store: store) {
            // TODO: only update value if value at the key is changed
            // TODO: do not change if value is not changed
            value = decoded
        }
    }
    
    static private func decodeValue(key: String, store: UserDefaults) -> Value? {
        try? store.data(forKey: key)?.jsonDecoded(Value.self)
    }
}
