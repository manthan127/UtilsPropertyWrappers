//
//  File.swift
//  
//
//  Created by Home on 10/01/26.
//

import Foundation
import SwiftUI
import Combine

// this will not work whre class uses @Observable macro
// @AppStorage is some how updating in directly view and from ObsevableObject, we are using different propertyWrapper
// TODO: try mearging AppStorageCodablePublished, AppStorageCodable in two one @propertyWrapper like appstorage

/// A property wrapper type that reflects a value from `UserDefaults` and
/// invalidates a view on a change in value in that user default.
@propertyWrapper
public struct AppStorageCodable<Value: Codable>: DynamicProperty {
    @StateObject private var storage: CodableStorage<Value>
    
    public init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) {
        _storage = .init(
            wrappedValue: CodableStorage<Value>(key: key, defaultValue: wrappedValue, store: store)
        )
    }
    
    public init(_ key: String, store: UserDefaults = .standard) where Value: ExpressibleByNilLiteral {
        _storage = .init(
            wrappedValue: CodableStorage<Value>(key: key, defaultValue: nil, store: store)
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

/// A property wrapper type that reflects a value from `UserDefaults` and
/// invalidates a view on a change in value in that user default.
@propertyWrapper
public struct AppStorageCodablePublished<Value: Codable>: DynamicProperty {
    private var storage: CodableStorage<Value>
    
    public init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) {
        storage = CodableStorage<Value>(key: key, defaultValue: wrappedValue, store: store)
    }
    
    public init(_ key: String, store: UserDefaults = .standard) where Value: ExpressibleByNilLiteral {
        storage = CodableStorage<Value>(key: key, defaultValue: nil, store: store)
    }
    
    public var wrappedValue: Value {
        get { storage.value }
        nonmutating set { storage.set(newValue) }
    }
    
    // this might be wrong // because @Published is returning Published<Value>.Publisher
    public var projectedValue: Binding<Value> {
        .init { storage.value } set: { storage.set($0) }
    }
    
    public static subscript<EnclosingSelf: ObservableObject>(
        _enclosingInstance instance: EnclosingSelf,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value {
        get {
            let storage = instance[keyPath: storageKeyPath].storage
            storage.publisher = instance.objectWillChange as? ObservableObjectPublisher
            return storage.value
        }
        set {
            let storage = instance[keyPath: storageKeyPath].storage
            storage.set(newValue)
        }
    }
}

fileprivate final class CodableStorage<Value: Codable>: ObservableObject {
    // this @Published might be why this is not working as expected inside ObsevableObject class
    @Published var value: Value
    
    private let key: String
    private let store: UserDefaults
    
    var publisher: ObservableObjectPublisher?
    
    init(key: String, defaultValue: Value, store: UserDefaults) {
        self.key = key
        self.store = store
        self.value = Self.decodeValue(key: key, store: store) ?? defaultValue
        
        startObserver()
    }
    
    func set(_ newValue: Value) {
        publisher?.send()
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
        if let decoded: Value = Self.decodeValue(key: key, store: store) {
            // TODO: only update value if value at the key is changed
            // TODO: do not change if value is not changed
            DispatchQueue.main.async {
                self.publisher?.send()
                self.value = decoded
            }
        }
    }
    
    fileprivate static func decodeValue(key: String, store: UserDefaults) -> Value? {
        try? store.data(forKey: key)?.jsonDecoded(Value.self)
    }
}
