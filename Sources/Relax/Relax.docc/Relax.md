# ``Relax``

Declaratively build and send client requests for REST APIs.

## Overview

![Relax logo](RelaxLogo.png)

Relax provides a way to declaratively define and organize client HTTP requests for REST APIs. The framework is
lightweight built on protocols, easily allowing you to structure your requests for even the most complex REST APIs.

### Features

- **Lightweight:** built on protocols, works directly on URLSession for low overhead
- **Declarative syntax:** using [result builders](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630),
allows for quickly and easily organizing requests to match any structure of REST API.
- **Modern:** Supports [Swift concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
(`async`/`await`) and [Combine](https://developer.apple.com/documentation/combine) (on macOS/iOS/watchOS/tvOS).

### Platforms

Available for all Swift (5.7+) platforms, including:

- macOS
- iOS
- watchOS
- tvOS
- Linux
- Windows

### Getting Started

Relax supports the [Swift Package Manager](). To integrate in your project-

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
