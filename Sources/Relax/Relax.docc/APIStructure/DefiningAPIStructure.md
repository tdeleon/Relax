# Defining an API Structure

Use Services and Endpoints to define a complex API structure

## Overview

While some REST APIs are simple, many are complex consisting of different path, query parameter, body, and HTTP method
combinations. The structure will often be nested by one or more levels.

Relax provides a great way to define these complex APIs- making it clear to read while reusing and inheriting as much as
possible. ``Service`` and ``Endpoint`` protocols are used to group multiple requests together.

## Services

A ``Service`` is a protocol you use to represent an entire API Service, at it's root level. Here, you define the base
URL of the service, along with any shared items you want all child requests to inherit, such as a common `URLSession`
and properties such as headers.

Here, we define a *UserService* with a base URL of *https://example.com/* and a common basic authorization header,
which all requests will use.

```swift
enum UserService: Service {
    static let baseURL = URL(string: "https://example.com/")!
    static var sharedProperties: Request.Properties {
        Headers {
            Header.authorization(.basic, value: "secretpassword")
        }
    }
}
```

Requests can be defined directly on the `Service`, with or without subsequent path components. For example, lets say we
have a stats API that can be called at the root (`/`) of the URL. This can be added directly to the `Service`, and will
define a `GET` request to the base URL, with the authorization header.

```swift
enum UserService: Service {
    static let baseURL = URL(string: "https://example.com/")!
    static var sharedProperties: Request.Properties {
        Headers {
            Header.authorization(.basic, value: "secretpassword")
        }
    }

    static let stats = Request(.get, parent: UserService.self)
}
```

> Tip: For more details on defining a ``Request``, see <doc:DefiningRequests>.

## Endpoints

Use the ``Endpoint`` type to define endpoints on a ``Service``. Multiple requests might be grouped under the same 
``Endpoint``- usually with the same URL (path), but with different method types or parameters.

Considering our *UserService* again, there may be an endpoint with the path */users* which provides various
operations on a *User* resource, such as fetching, modifying, or deleting an existing user, or adding a new one. It may
also allow for fetching all users. There are different specific designs one could use to accomplish this, and Relax aims
to be flexible to allow for different ones.

The ``Endpoint`` protocol is helpful here because it can be used to group these common requests together. It requires a
**path** be defined, so in this case it would be *users*. We set the `Parent` to be *UserService*, to indicate that this
endpoint is part of the ``Service``, so all requests defined on it will share the URL and properties from *UserService*.

```swift
enum UserService: Service {
    static let baseURL = URL(string: "https://example.com/")!
    static var sharedProperties: Request.Properties {
        Headers {
            Header.authorization(.basic, value: "secretpassword")
        }
    }

    enum Users: Endpoint {
        // /users appended to base URL: https://example.com/users
        static let path = "users"
        // connect Users to UserService
        typealias Parent = UserService

        // GET request
        static var getAll = Request(.get, parent: UserService.self)

        // GET request with query parameters
        @RequestBuilder<Users>
        static func get(with name: String) -> Request {
            Request.HTTPMethod.get
            QueryItems { ("name", name) }
        }

        // POST request with User JSON encoded in the body
        @RequestBuilder<Users>
        static func add(_ new: User) -> Request {
            Request.HTTPMethod.post
            Body { new }
        }
    }
}
```

To send the requests:
```swift
// get all users
// resolves to GET 'https://example.com/users'
Task {
    do {
        let users: [User] = try await UserService.Users
            .getAll()
            .send()
        print(users)
    } catch {
        print(error)
    }
}
```

```swift
// get a single user
// resolves to GET 'https://example.com/users?name=John'
Task {
    do {
        let users: [User] = try await UserService.Users
            .get(with: "John")
            .send()
        print(users)
    } catch {
        print(error)
    }
}
```

```swift
// add a user
// resolves to POST 'https://example.com/users' with a JSON encoded User in the body
Task {
    do {
        let newUser = User(name: "John")
        try await UserService.Users.add(newUser)
    } catch {
        print(error)
    }
}
```

> Tip: See <doc:SendingRequestsAsync>, <doc:SendingRequestsPublisher>, or <doc:SendingRequestsHandler> for how to send requests you've defined.
