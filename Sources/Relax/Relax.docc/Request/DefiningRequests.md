# Defining Requests

Define a Request to send and receive data from a REST API

## Overview

You can create Requests in several different ways, ranging from as simple as a one-shot request to a URL, or a complex
definition of an entire REST API service. They can be either pre-defined and static, or accept dynamic parameters at
runtime, depending on your needs.

Once you've created your request, see <doc:SendingRequestsAsync>, <doc:SendingRequestsPublisher>, or <doc:SendingRequestsHandler> on how to send them and receive a response.

## Request Basics

At a minimum, a request needs a URL and HTTP method type (`GET`, `POST`, `PUT`, etc) to be defined:
```swift
// Creates a GET request to 'https://example.com/users'
// with no headers, query parameters, or body.
let request = Request(.get, url: URL(string: "https://example.com/users")!)
```

### Setting Properties

Usually, you will need to customize at least some other properties on the request, such as headers or query items.
``Request``s have the following properties available to be set for each request:

- ``Headers``
- ``QueryItems``
- ``Body``
- ``PathComponents``

These can be set using the `properties` parameter on the init method, which takes a ``Request/Properties/Builder``
closure where you set any number of properties to be used in the request using a [result builder](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630).

The following builds on the previous example by adding a `Content-Type: application/json` header and appending a query
parameter to the URL, so the final URL will be `https://example.com/users?name=firstname`.

```swift
let request = Request(.get, url: URL(string: "https://example.com/users")!) {
    Headers {
        Header.contentType(.applicationJSON)
    }
    QueryItems {
        ("name","firstname")
    }
}
```

For some requests, you will need to send data in the request body, for example often with a `POST` request when
creating a new object. You can do this with the ``Body`` property as shown. Note how an `Encodable` object is added
directly and automatically encoded into JSON data.

```swift
let request = Request(.post, url: URL(string: "https://example.com/users")!) {
    Body {
        // Assume that User is an Encodable type
        User(name: "firstname")
    }
}
```

### Request Session

When sending requests, a `URLSession` is used, which can be configured through the ``Request/session`` property. If not
specified, this property will inherit from the
[`parent`](<doc:Request/init(_:parent:configuration:session:properties:)>) if defined, otherwise it will be set to
`URLSession.shared` by default. See <doc:DefiningAPIStructure> for more on inheritance.

```swift
enum MyService: Service {
     static let baseURL = URL(string: "https://example.com/")!
     static let session: URLSession = mySession // use a specific URLSession already defined

     // request will use session defined in MyService, mySession
     static let get = Request(.get, parent: MyService.self)

     // request will use URLSession.shared, overriding the parent session
     static let getSharedSession = Request(.get, parent: MyService.self, session: .shared)
 }
 ```

If a request does not have a parent set, then the session will default to `URLSession.shared`, if not otherwise
specified.

```swift
// a request using URLSession.shared
let request = Request(.get, url: URL(string: "https://example.com/")!)

// a request using a specific URLSession
let customSessionRequest = Request(.get, url: URL(string: "https://example.com/")!, session: mySession)
```
### Configuring a Request

Sometimes you need more control on a request to modify things such as the timeout interval or cache policy. This can
be done using the ``Request/Configuration-swift.struct`` structure. The following example changes the timeout interval
to 90 seconds instead of the default 60.

```swift
let request = Request(
        .post, 
        url: URL(string: "https://example.com/users")!,
        configuration: Request.Configuration(timeout: 90)
    ) {
    Body {
        // Assume that User is an Encodable type
        User(name: "firstname")
    }
}
```

If no configuration is specified, then the configuration will be inherited from the requests parent ``APIComponent``.
If the request is standalone (not linked to a parent), then a
 [`default`](<doc:Request/Configuration-swift.struct/default>) configuration will be used.

See <doc:DefiningAPIStructure> for more on inheritance.

### Modifying a Request

While many properties can be pre-defined on requests, there may be cases where values need to be changed after
the request is defined, but before it is sent. In this case, there are modifier style methods available for
adding/changing/deleting a ``RequestProperty`` and for modifying headers.

```swift
let request = Request(.get, url: URL(string: "https://example.com/users")!) {
    QueryItems {
        ("filter", true)
    }
}

// adds the query item to any existing query items already part of the request 
try await request
        .adding(
            QueryItems { ("name", "firstname") }
        )
        .send()

// sets a header on the request 
try await request
        .settingHeader(name: "name", value: "value")
        .send()
```

For more information on modifying requests, see ``Request``.

## Requests in a Complex Structure

With a large API service, there will often be many different requests (often nested at different levels) that you want
to organize and reuse. A ``Request`` allows for inheriting shared values among groups of requests, such as the base URL
and properties.

> Note: For a full discussion on how to define complex API structures, see <doc:DefiningAPIStructure>.

When you have defined a ``Service`` and optionally ``Endpoint``s, you can inherit their properties by passing their
type to the Request init method. The `parent` parameter takes an ``APIComponent`` type, which both ``Service`` and
``Endpoint`` conform to. When providing the parent type, you do not need to provide a base URL to the Request.

Note in the following example how the base URL does not need to be provided to either of the requests, as they inherit
it from the `UserService`. Also, since the `sharedProperties` property was provided, each child request will
use the authorization header provided.

> Tip: When using ``Service``s or ``Endpoint``s as shown, it is not required for the requests to be nested under them
as shown- they can still inherit from them as long as the parent type is provided. However, nesting this way may better
help organize requests and make your code easier to read.

```swift
enum UserService: Service {
    static let baseURL = URL(string: "https://example.com/users")!

    static var sharedProperties: Request.Properties {
        Headers {
            Header.authorization(.basic, value: "secret password")
        }
    }

    // get all users
    static let getUsers = Request(.get, parent: Self.self)

    // get user with name
    static func getUser(name: String) -> Request {
        Request(.get, parent: Self.self) {
            QueryItems { ("name", name) }
        }
    }
}
```

Another way to define requests inside a structure is using a ``RequestBuilder``. The following provides equivalent
requests, but allows for a different syntax to the above:

```swift
enum UserService: Service {
    static let baseURL = URL(string: "https://example.com/")!

    static var sharedProperties: Request.Properties {
        Headers {
            Header.authorization(.basic, value: "secret password")
        }
    }

    enum Users: Endpoint {
        static let path = "users"
        typealias Parent = UserService

        @RequestBuilder<Users>
        static var getUsers: Request {
            Request.HTTPMethod.get
        }

        @RequestBuilder<Users>
        static func getUser(name: String) -> Request {
            Request.HTTPMethod.get
            QueryItems { ("name", name) }
        }
    }
}
```
