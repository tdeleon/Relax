# ``Relax/Body``

## Overview

Use this structure to define the body of a request.

```swift
// You can use any Data or Encodable values (assume `User` is Encodable)
Body {
    "Hello".data(using: .utf8)
    User(name: "Tom")
}
```

## Topics

### Defining a Request Body

- ``init(_:)``
- ``init(_:encoder:)``
- ``init(_:options:)``
- ``init(value:)``
