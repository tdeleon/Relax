# ``Relax/Headers``

## Overview

Use this structure to define the headers of a request.

```swift
// Assume token is a bearer token received elsewhere
Headers {
    Header.accept(.applicationJSON)
    Header.authorization(.bearer, value: token)
}
```

## Topics

### Defining Request Headers

- ``init(_:)``
- ``init(headers:)``
- ``init(value:)``

### Defining a Single Header

- ``Header``
- ``Header/Name-swift.struct``

