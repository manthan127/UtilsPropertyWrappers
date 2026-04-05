# UtilsPropertyWrappers

Minimum supported platforms:

- macOS 11.0
- iOS 14.0
- tvOS 14.0
- watchOS 7.0

## Property wrappers

This package includes three wrappers:

- [`@AppStorageCodable<Value: Codable>`](#appstoragecodable)
- [`@AppStorageCodablePublished<Value: Codable>`](#appstoragecodablepublished)
- [`@DecodedFromString<Value: OptionalStringConvertibleProtocol>`](#decodedfromstring)

### AppStorageCodable

`@AppStorageCodable` works like SwiftUI's `@AppStorage`, but it stores any `Codable` model in `UserDefaults` by encoding and decoding it automatically.

**Use case:** Persist small `Codable` models in `UserDefaults` without writing custom encode/decode logic. Use this in SwiftUI views.

Example:

```swift
struct Settings: Codable {
    var theme: String = "light"
    var notificationsEnabled: Bool = true
}

struct ContentView: View {
    @AppStorageCodable("settingsKey") private var settings = Settings()

    var body: some View {
        Form {
            Toggle("Enable notifications", isOn: $settings.notificationsEnabled)
            Text("Theme: \(settings.theme)")
        }
    }
}
```

If your model is optional, use the optional initializer:

```swift
@AppStorageCodable("settingsKey") private var settings: Settings? = nil
```

### AppStorageCodablePublished

`@AppStorageCodablePublished` is similar to `@AppStorageCodable`, but it is designed to work inside an `ObservableObject` and publish changes through `objectWillChange`.

**Use case:** Share app settings between SwiftUI views and `ObservableObject` classes, ensuring all observers are notified of changes.

Example:

```swift
final class SettingsModel: ObservableObject {
    @AppStorageCodablePublished("settingsKey") var settings = Settings()
}

struct ContentView: View {
    @StateObject private var model = SettingsModel()

    var body: some View {
        Form {
            Toggle("Enable notifications", isOn: $model.settings.notificationsEnabled)
            Text("Theme: \(model.settings.theme)")
        }
    }
}
```

### DecodedFromString

Use it when an API returns numeric or boolean values as strings, but your data model expects the real typed value.

**Use case:** Decode APIs that return numeric or boolean values as strings without writing custom initializers or extra computed properties.

It supports types that conform to `OptionalStringConvertibleProtocol`, including `Int`, `Double`, `Bool`, `String`, and their optional variants.

Example:

```swift
struct ApiResponse: Decodable {
    @DecodedFromString var id: Int
    @DecodedFromString var price: Double?
    @DecodedFromString var isActive: Bool
}
```

This lets your model decode values like `"123"`, `"19.99"`, or `"true"` seamlessly.
