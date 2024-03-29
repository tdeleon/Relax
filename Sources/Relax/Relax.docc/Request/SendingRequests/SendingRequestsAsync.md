# Sending Requests Asynchronously

Send a Request asynchronously with Swift concurrency.

## Overview

You can send a ``Request`` which will [`await`](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
completion in concurrent code. Errors are thrown from the method, which you catch in a `do/catch` block.

## Sending a Request

### Customizing the URLSession Used

You can optionally provide your own `URLSession` to use, otherwise `URLSession.shared` will be used.

### Sending the Request

Use ``Request/send(session:)-74uav`` to receive `Data` from a request.

```swift
Task {
    do {
        let response = try await request.send()
        print("Data: \(String(data: response.data, encoding: .utf8))")
        print("Status: \(response.statusCode)")
    }
    catch {
        print("Request failed - \(error.localizedDescription)")
    }
}
```

### Overriding the Request Session

Requests are sent using a `URLSession`, which is customizable through the ``Request/session`` property. If
the request is linked to a `parent` ``APIComponent``, then the session will inherit from the ``APIComponent/session`` by
default. This can be overridden when a request is sent by passing in a specific `URLSession`:

```swift
// Uses the session and configuration defined on MyService by default
let response = try await MyService.get.send()

// Uses a custom URLSession & Configuration for this send only
let response = try await MyService.get.send(session: customSession)
```

For detached requests (with no parent), `URLSession.shared` is used by default if no other session is specified:

```swift
// Uses URLSession.shared
let response = try await Request(.get, url: URL(string: "https://example.com/")!)

// Uses a specific URLSession
let response = try await Request(.get, url: URL(string: "https://example.com/")!, session: customSession)
```

See <doc:DefiningAPIStructure> for more on inheritance.

### Decoding JSON

You can automatically decode JSON into an expected `Decodable` instance using the
``Request/send(decoder:session:)-667nw`` method.

> Tip: The ``Request/decoder`` defined in the request is used by default, but you can pass in your own to override this.

```swift
Task {
    do {
        let request = Request(.get, url: URL(string: "https://example.com")!)
        let user: User = try await request.send()
        print("Received user: \(user)")
    }
    catch {
        print("Request failed - \(error.localizedDescription)")
    }
}
```

### Handling Errors

When a failure occurs, ``RequestError`` is thrown. By default, HTTP status codes (`4XX`, `5XX`, etc) returned from the
server are not parsed for errors. As a convenience, you can set the
``Request/Configuration-swift.struct/parseHTTPStatusErrors`` parameter in ``Request/Configuration-swift.struct`` to
`true` in order to enable this. If enabled, then any HTTP status code outside the `1XX`-`3XX` range will be treated as
an error.
