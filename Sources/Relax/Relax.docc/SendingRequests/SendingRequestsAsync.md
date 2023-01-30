# Sending Requests Asynchronously

Send a Request asynchronously with Swift concurrency.

## Overview

You can send a ``Request`` which will [`await`](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) completion
in concurrent code. Errors are thrown from the method, which you catch in a `do/catch` block.

## Sending a Request

### Customizing the URLSession Used

You can optionally provide your own `URLSession` to use, otherwise `URLSession.shared` or any ``Service/session-5836y`` defined on the parent ``Service`` will be used.

### Sending the Request

Use ``Request/send(session:parseHTTPStatusErrors:)-51tcd`` to receive `Data` from a request.

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

### Decoding JSON

You can automatically decode JSON into an expected `Decodable` instance using the ``Request/send(decoder:session:parseHTTPStatusErrors:)-2nvfo`` method.

> Tip: By default, `JSONDecoder()` is used, but you
can also pass in your own to the `decoder` parameter.

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

When a failure occurs, ``RequestError`` is thrown. By default, HTTP status codes (`4XX`, `5XX`, etc) returned from the server are not parsed for errors. As a convenience, you can set the `parseHTTPStatusErrors` parameter to `true` in order to enable this. If enabled, then any HTTP status code outside the `1XX`-`3XX` range will be treated as an error.
