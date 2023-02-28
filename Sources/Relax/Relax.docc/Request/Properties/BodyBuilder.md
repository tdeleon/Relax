# ``Relax/Body/Builder``

A result builder that you use to compose a ``Body`` instance.

## Overview

This result builder combines any number of ``Body``, `Data`, `Encodable`, or dictionary instances to a single 
``Body`` instance, with support for conditionals.

Each component will be converted to `Data` and appended to each other, from top to bottom. You can use this 
builder in any closure with the `@Body.Builder` attribute.

```swift
// Encoding a string as Data
Body {
    "Hello".data(using: .utf8)
}

// Equivalent to appending the two instances of Data together
Body {
    "Hello".data(using: .utf8)
    "World".data(using: .utf8)
}

// Dictionaries serialized to Data
Body {
    ["key": "value]
}

// Encoding an Encodable instance
Body {
    User(name: "Tom")
}

// Data, dictionary, and Encodable instances can be mixed
Body {
    "Hello".data(using: .utf8)
    ["key": "value"]
    User(name: "Tom")
}
```
