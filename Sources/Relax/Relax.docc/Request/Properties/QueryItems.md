# ``Relax/QueryItems``

## Overview

Use this structure to define the query items of a request. The query items will be appended to the request URL.

```swift
// Assume firstName is a String variable
QueryItems {
    ("sort": true)
    URLQueryItem(name: "filter", value: firstName)
}
```

## Topics

### Defining Request Query Items

- ``init(_:)``
- ``init(value:)``

### Defining a Single Query Item

- ``QueryItem``
- ``QueryItem/Name-swift.struct``
