# Sending Requests using a Completion Handler

Send a request calling a handler upon completion.

## Overview

You can send a ``Request`` which calls a completion handler closure when a response is received. A `URLSessionDataTask` is returned, which `resume()` will automatically be called by default.

## Sending a Request

### Customizing the URLSession Used

You can optionally provide your own `URLSession` to use, otherwise `URLSession.shared` or any ``Service/session-5836y`` defined on the parent ``Service`` will be used.

### Sending the Request

Use ``Request/send(session:autoResumeTask:completion:)`` to send the
request to the server. When a response (or error) is received, the completion handler ``Request/Completion`` will be called with the received data.

> Warning: This method returns a `URLSessionDataTask`, which `resume()` is already called by default. If you call `resume()` on the task again, then the request will be sent a second time, unless the `autoResumeTask` parameter is set to `false`.

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

You can automatically decode received data into a `Decodable` instance with the ``Request/send(decoder:session:completion:)`` method. This method also uses a completion handler, but instead of `Data`, returns the data decoded to a `Decodable` type.

> Tip: By default, `JSONDecoder()` is used, but you can also pass in your own to the `decoder` parameter.

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

### Handling Errors

When a failure occurs, ``RequestError`` is the failure type of the result returned in the completion handler. By default, HTTP status codes (`4XX`, `5XX`, etc) returned from the server are not parsed for errors. As a convenience, you can set the ``Request/Configuration-swift.struct/parseHTTPStatusErrors`` parameter in ``Request/Configuration-swift.struct`` to `true` in order to enable this. If enabled, then any HTTP status code outside the `1XX`-`3XX` range will be treated as an error.
