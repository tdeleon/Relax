# ``Relax``

Declaratively build and send client requests for REST APIs in Swift.

## Overview

![Relax logo](RelaxLogo.png)

Relax provides a way to declaratively define and organize client HTTP requests for REST APIs. The framework is
lightweight built on protocols, easily allowing you to structure your requests for even the most complex REST APIs.

### Features

- **Lightweight:** built on protocols, works directly on URLSession for low overhead
- **Declarative syntax:** using [result builders](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630),
allows for quickly and easily organizing requests to match any structure of REST API.
- **Modern:** Supports [Swift concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
(`async`/`await`) and [Combine](https://developer.apple.com/documentation/combine) (on Apple platforms).

### Supported Platforms

Available for all Swift (5.7+) platforms, including:

| Platform | Minimum Version |
|----------|-----------------|
| macOS    | 12.0            |
| iOS      | 14.0            |
| watchOS  | 7.0             |
| tvOS     | 14.0            |
| Linux    | Swift 5.7*      |
| Windows  | Swift 5.7*      |

*Works on any version where Swift 5.7 is supported.

### Getting Started

Relax supports the [Swift Package Manager](https://www.swift.org/package-manager/). To integrate in your project-

1. Add the following to the **package** dependencies in the *Package.swift* manifest file:

    ```swift
    dependencies: [
        .package(url: "https://github.com/tdeleon/Relax.git", from: "2.0.0")
    ]
    ```

2. Add *Relax* to the **target** dependencies:

    ```swift
    targets: [
        .target(
            name: "YourProject",
            dependencies: ["Relax"])
    ]
    ```

In files where you will be using Relax, import the framework:

```swift
import Relax
```

### Make a Simple Request

```swift
do {
    let request = Request(.get, url: URL(string: "https://example.com/users")!)
    try await request.send()
} catch {
    print(error)
}
```

## Topics

### Defining Requests

- <doc:DefiningRequests>
- ``Request``
- ``RequestBuilder``
- ``RequestProperty``
- ``Body``
- ``Headers``
- ``QueryItems``
- ``PathComponents``

### Sending Requests

- <doc:SendingRequestsAsync>
- <doc:SendingRequestsPublisher>
- <doc:SendingRequestsHandler>

### Defining An API Structure

- <doc:DefiningAPIStructure>
- ``Service``
- ``Endpoint``
- ``APIComponent``
- ``APISubComponent``

### Handling Errors

- ``Relax/RequestError``
- ``Relax/RequestError/HTTPError``
