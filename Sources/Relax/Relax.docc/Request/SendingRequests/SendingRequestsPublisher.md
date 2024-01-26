# Sending Requests with a Publisher

Send a Request using a Combine publisher

## Overview

You can send a ``Request`` which will return a [Combine publisher](https://developer.apple.com/documentation/combine)
which publishes data when the request is completed.

## Sending a Request

### Customizing the URLSession Used

You can optionally provide your own `URLSession` to use, otherwise `URLSession.shared` will be used.

### Sending the Request

Use ``Request/send(session:)-8vwky`` to return a publisher which
upon receiving a response from the server, will publish a ``Request/PublisherResponse``.

```swift
let request = Request(.get, url: URL(string: "https://example.com")!)
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
```

### Overriding the Request Session

Requests are sent using a `URLSession`, which is customizable through the ``Request/session`` property. If
the request is linked to a `parent` ``APIComponent``, then the session will inherit from the ``APIComponent/session`` by
default. This can be overridden when a request is sent by passing in a specific `URLSession`:

```swift
// Uses the session and configuration defined on MyService by default
cancellable = MyService.get.send()
    .sink(receiveCompletion: { completion in
        ...
    }, receiveValue: { response in
        ...
    })

// Uses a custom URLSession & Configuration for this send only
cancellable = MyService.get.send(session: customSession)
    .sink(receiveCompletion: { completion in
        ...
    }, receiveValue: { response in
        ...
    })
```

For detached requests (with no parent), `URLSession.shared` is used by default if no other session is specified:

```swift
// Uses URLSession.shared
let request = Request(.get, url: URL(string: "https://example.com")!)
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

// Uses a specific URLSession
let request = Request(.get, url: URL(string: "https://example.com")!)
cancellable = request.send(session: customSession)
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
```

See <doc:DefiningAPIStructure> for more on inheritance.

### Decoding JSON

You can automatically decode received data into a `Decodable` instance with the``Request/send(decoder:session:)-3j2hs``,
which will publish a ``Request/PublisherModelResponse`` with the decoded data.

> Tip: The ``Request/decoder`` defined in the request is used by default, but you can pass in your own to override this.

```swift
let request = Request(.get, url: URL(string: "https://example.com")!)
cancellable = try request.send()
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
```

### Handling Errors

When a failure occurs, ``RequestError`` is the `Failure` of the publisher returned. By default, HTTP status codes
(`4XX`, `5XX`, etc) returned from the server are not parsed for errors. As a convenience, you can set the
``Request/Configuration-swift.struct/parseHTTPStatusErrors`` parameter in ``Request/Configuration-swift.struct`` to
`true` in order to enable this. If enabled, then any HTTP status code outside the `1XX`-`3XX` range will be treated as
an error.
