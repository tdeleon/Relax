# Sending Requests with a Publisher

Send a Request using a Combine publisher

## Overview

You can send a ``Request`` which will return a [Combine publisher](https://developer.apple.com/documentation/combine) which
publishes data when the request is completed.

## Sending a Request

### Customizing the URLSession Used

You can optionally provide your own `URLSession` to use, otherwise `URLSession.shared` or any ``Service/session-5836y`` defined on the parent ``Service`` will be used.

### Sending the Request

Use ``Request/send(session:parseHTTPStatusErrors:)-2a2id`` to return a publisher which
upon receiving a response from the server, will publish a ``Request/PublisherResponse``.

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

You can automatically decode received data into a `Decodable` instance with the
``Request/send(decoder:session:parseHTTPStatusErrors:)-4i33g``, which will publish a
``Request/PublisherModelResponse`` with the decoded data.

> Tip: By default, `JSONDecoder()` is used, but you can also pass in your own to the `decoder` parameter.

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

### Handling Errors

When a failure occurs, ``RequestError`` is the `Failure` of the publisher returned. By default, HTTP status codes (`4XX`, `5XX`, etc) returned from the server are not parsed for errors. As a convenience, you can set the `parseHTTPStatusErrors` parameter to `true` in order to enable this. If enabled, then any HTTP status code outside the `1XX`-`3XX` range will be treated as an error.
