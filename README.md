
<h1 style="text-align: center;"><img src="https://user-images.githubusercontent.com/3507743/82412732-08c9c900-9a29-11ea-9eb4-0f7caea45e6e.png" height="60" style="vertical-align: middle; padding-right: 20px">Relax</h1>

---

[![License](https://img.shields.io/github/license/tdeleon/Relax)](https://github.com/tdeleon/Relax/blob/master/LICENSE)
[![Swift](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftdeleon%2FRelax%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/tdeleon/Relax)
[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen)](https://swift.org/package-manager/)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux%20%7C%20Windows-blue)](https://www.swift.org/platform-support/)
[![Test](https://github.com/tdeleon/Relax/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/tdeleon/Relax/actions/workflows/test.yml?query=branch%3Amain++)

*Declaratively build and send client requests for REST APIs in Swift.*

## Overview

Relax provides a way to declaratively define and organize client HTTP requests for REST APIs. The framework is
lightweight built on protocols, easily allowing you to structure your requests for even the most complex REST APIs.

### Full Reference Documentation

https://swiftpackageindex.com/tdeleon/relax/documentation

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

#### Using a Package Manifest File

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

#### Using an Xcode Project

1. In your project, choose **File > Add Package Dependencies...**

2. Select the desired criteria, and click **Add Package**

3. In the Package Product selection dialog, select **your target** in the *Add to Target* column for the *Package Product*
**Relax**. Leave **URLMock** set to **None**, unless you have a test target.

4. Click on **Add Package**

>Tip: `URLMock` is an additional framework provided to aid in testing by mocking responses to requests, and should be
added to your test targets only. For more information, see <doc:Relax#Testing> below.

#### Import the framework

In files where you will be using Relax, import the framework:

```swift
import Relax
```

### Make Requests

You can make very simple requests:
```swift
do {
    let request = Request(.get, url: URL(string: "https://example.com/users")!)
    try await request.send()
} catch {
    print(error)
}
```
Or, more complex requests with multiple properties:
```swift
let request = Request(.post, url: URL(string: "https://example.com/users")!) {
    Body {
        // Send an Encodable user object as JSON in the request body
        User(name: "firstname")
    }
    Headers {
        Header.authorization(.basic, value: "secret-123")
        Header.contentType(.applicationJSON)
    }
}
```

See <doc:DefiningRequests> for more details.

### Define a Complex API Structure

You can organize groups of requests into structures of ``Service``s and ``Endpoint``s, inheriting a common base URL and
properties:

```swift
enum UserService: Service {
    static let baseURL = URL(string: "https://example.com/")!
    // Define shared properties for any request/endpoint children
    static var sharedProperties: Request.Properties {
        Headers {
            Header.authorization(.basic, value: "secretpassword")
        }
    }

    // define a /users endpoint
    enum Users: Endpoint {
        // /users appended to base URL: https://example.com/users
        static let path = "users"
        // connect Users to UserService
        typealias Parent = UserService

        // GET request
        static var getAll = Request(.get, parent: UserService.self)
    }
}

// make a get request to https://example.com/users
let users = try await UserService.Users.getAll.send()
```

See <doc:DefiningAPIStructure> for more details.

## Testing

[URLMock](https://swiftpackageindex.com/tdeleon/relax/documentation/urlmock) is a framework for mocking responses to
`URLSession` requests, and is included in the Relax package as a second library target. 

This allows you to test all ``Request``s by using a `URLSession` that returns mock content only, never making a real
request over the network. Convenience methods are provided for common responses such as HTTP status codes, JSON, and
errors.

To use, simply add `URLMock` as a dependency in your `Package.swift` file or in Xcode to your test target(s):

```swift
.testTarget(
    name: "MyAppTests",
    dependencies: ["Relax", "URLMock"]),
```

>Note: The `URLMock` framework is intended for testing use only. It is highly encouraged to include it as a
dependency in your test targets only.

Next, in your tests, include the `URLMock` framework along with `Relax` and the target being tested:

```swift
import XCTest
import Relax
import URLMock
@testable import MyApp
```
Finally, create a `URLSession` providing a mocked response, and use it with a ``Request``:

```swift
// Create a session which returns a URLError
let session = URLMock.session(.mock(.notConnectedToInternet))
// Make a request using the modified session. An error should be thrown
do {
    try await MyAPIService.Endpoint.get.send(session: session)
    XCTAssertFail("Should have failed")
} catch {
    // Validate error is handled correctly
}
```

For further examples, see the [full documentation](https://swiftpackageindex.com/tdeleon/relax/documentation/urlmock).
