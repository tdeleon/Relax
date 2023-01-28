# Sending Requests

Send a Request to a server and receive a response.

## Overview

Once a ``Request`` is created, it can be sent to a server and a response received. Relax provides several ways to do this,
using concurrency (async/await), a Combine publisher (where available by platform), or completion handler closure.

Additionally, as a convenience, if your expected response is a model Decodable type, the framework can automatically
decode the data returned from the server.

### Customizing the URLSession

You can optionally provide your own `URLSession` to use, otherwise `URLSession.shared` or any session defined on the
request's parent (if provided) will be used.

### Handling Errors

``RequestError`` is thrown (returned for completion handlers) which indicates a problem actually sending the request
and does not treat any HTTP status codes (4XX, 5XX, etc) returned from the server as errors. As a convenience, you can
pass `true` to the `parseHTTPStatusErrors` parameter to enable this. If enabled, then any HTTP status codes outside the
1XX-3XX range will be treated as an error.

- Note: For the examples below, assume that `request` is a request already defined. For information on how to create
requests, see

## Sending Requests Asynchronously

You send a request asynchronously using the ``Request/send(session:parseHTTPStatusErrors:)-51tcd`` method. Errors are
thrown from the method, which you catch in a do/catch block.

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

Relax can automatically decode JSON into an expected `Decodable` instance using the ``Request/send(decoder:session:parseHTTPStatusErrors:)-2nvfo`` method. By default, `JSONDecoder()` is used, but you
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

## Sending Requests Using a Publisher

You send a request asynchronously using the ``Request/send(session:parseHTTPStatusErrors:)-2a2id`` method. Errors are
thrown from the method, which you catch in a do/catch block.

```swift
let request = Request(.get, url: URL(string: "https://example.com")!)
do {
    cancellable = request.send()
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Request failed - \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { response in
            print("Data: \(String(data: response.data, encoding: .utf8))")
            print("Status: \(response.urlResponse.statusCode)")
        })
}
```

### Decoding JSON

Relax can automatically decode JSON into an expected `Decodable` instance using a publisher with the 
``Request/send(decoder:session:parseHTTPStatusErrors:)-4i33g`` method. By default, `JSONDecoder()` is used, but you 
can also pass in your own to the `decoder` parameter.

```swift
let request = Request(.get, url: URL(string: "https://example.com")!)
do {
    cancellable = request.send()
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("Request failed - \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { response in
            print("User: \(response.responseModel)")
        })
}
```

## Sending Requests Using Completion Handlers

To send a request using a completion handler to handle the response, use the ``Request/send(session:autoResumeTask:parseHTTPStatusErrors:completion:)`` method.

```swift
let request = Request(.get, url: URL(string: "https://example.com")!)
request.send { result in
    switch result {
    case .success(let response):
        print("Data: \(String(data: response.data, encoding: .utf8))")
        print("Status: \(response.urlResponse.statusCode)")
    case .failure(let error):
        print("Request failed - \(error.localizedDescription)")
    }
}
```

### Decoding JSON

To decode JSON using a completion handler, use the ``Request/send(decoder:session:parseHTTPStatusErrors:completion:)``
method.

```swift
let request = Request(.get, url: URL(string: "https://example.com")!)
request.send { (result: Result<User, RequestError> in
    switch result {
    case .success(let user):
        print("User: \(user)")
    case .failure(let error):
        print("Request failed - \(error.localizedDescription)")
    }
}
```
