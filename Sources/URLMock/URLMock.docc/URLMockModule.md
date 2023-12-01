# ``URLMock``

Conveniently mock responses to URLSession requests.

## Overview

URLMock provides a way to mock responses on a URLSession, without using a network. This is done through an
implementation of `URLProtocol` which returns the provided mocked response.

Responses are fully customizable with an `HTTPURLResponse`, data, and optional error; or convenience responses can be
used.

## Getting Started

To configure a `URLSession` for using mocked responses, a convenience function is provided:

```swift
// Use a default mocked response with a 204 status code
let session = URLMock.session()
```

> Note: If no response is provided when creating the session, then a default response is used consisting of an HTTP
status code of `204` (no content), empty data (`Data()`), and no error.

To customize the response for all requests to the session, provide a ``MockResponse`` to the `response`
parameter.

```swift
// create a session with a 404 response code
let session = URLMock.session(.mock(404))
```

You can change the mocked response at any time without creating a new `URLSession` by setting the
``URLMock/response`` property:

```swift
// create a session with a 404 response code
let session = URLMock.session(.mock(404))
// changes the response to a 204 status code, without needing to create a new session
URLMock.response = .mock()
// changes the response to notConnectedToInternet error
URLMock.response = .mock(.notConnectedToInternet)
```

>Important: As ``URLMock/response`` is a static property, the response set will apply to all `URLSession` instances using
``URLMock``.

## Customizing Responses

You will often want to return more than a status code, such as JSON or an Error. Convenience methods are
provided for this.

Providing a response from a Codable object:

```swift
// given a Codable object 'User'
let user = User(name: "name")
// create a session with a response returning the model object as Data
let session = URLMock.session(.mock(user))
```

Providing a response from a URLError:

```swift
// create a session which returns a response with a Not Connected To Internet code
let session = URLMock.session(.mock(.notConnectedToInternet))
```

To see other ways to customize responses, see ``MockResponse``.

## Validating Requests

To validate the parameters of the request being made, the ``MockResponse/onReceive`` property is
provided. This is called when the request is received, before the response is returned. The request is provided as
the parameter of the closure.

```swift
let session = URLMock.session(.mock(.notConnectedToInternet) { received in
    // validate request properties are correct
    XCTAssertEqual(received.httpMethod, "GET")
})
```

To assist in validating requests, extension methods on `URLRequest` are
[provided for convenience](<doc:Foundation/URLRequest>).

```swift
// given a Codable object 'User'
let newUser = User(name: "name")
// create a session with a response returning 204; validate the request
let session = URLMock.session(.mock { received in
    XCTAssertEqual(recieved.httpMethod, "POST")
    try received.validateBody(matches: newUser)
})

// Assuming a defined POST request which sends a User in the request body,
// make the request
try await Users.add(newUser).send(session: session)
```

## Topics

### Creating a Session Using Mock Responses

- ``URLMock/session(_:configuration:delegate:delegateQueue:)``

### Mocking Responses

- ``MockResponse``

### Validating Requests

- ``Foundation/URLRequest``
