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
let session = URLMock.session(.mock(statusCode: 404))
```

You can change the mocked response at any time by setting the ``URLMock/response`` property:

```swift
// create a session with a 404 response code
let session = URLMock.session(response: .mock(statusCode: 404)
// changes the response to a 204 status code, without needing to create a new session
URLMock.response = .mock()
```

## Customizing Responses

You will often want to return more than a status code, such as JSON or an Error. Convenience methods are
provided for this.

Providing a response from a Codable object:

```swift
// given a Codable object 'User'
let user = User(name: "name")
// create a session with a response returning the model object as Data
let session = URLMock.session(response: .mock(user))
```

Providing a response from a URLError:

```swift
// create a session which returns a response with a Not Connected To Internet code
let session = URLMock.session(response: .mock(.notConnectedToInternet))
```

To see all possible responses, see ``MockResponse``.

## Validating a Request

To validate the parameters of the request being made, the ``MockResponse/onReceive`` property is
provided. This is called when the request is received, before the response is returned. The request is provided as
the parameter of the closure.

## Topics

### Creating a Mocked Session

- ``URLMock/session(_:configuration:delegate:delegateQueue:)``

### Mocking Responses

- ``MockResponse``
- ``MockResponse/mock(delay:onReceive:response:)``
- ``MockResponse/mock(_:data:error:delay:onReceive:)-75apm``
