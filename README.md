
<h1 style="text-align: center;"><img src="https://user-images.githubusercontent.com/3507743/82412732-08c9c900-9a29-11ea-9eb4-0f7caea45e6e.png" height="60" style="vertical-align: middle; padding-right: 20px">Relax</h1>

---

[![GitHub](https://img.shields.io/github/license/tdeleon/Relax)](https://github.com/tdeleon/Relax/blob/master/LICENSE)
[![Swift](https://img.shields.io/badge/Swift-5.2-brightgreen.svg?colorA=orange&colorB=4E4E4E)](https://swift.org)
[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen)](https://swift.org/package-manager/)
[![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux-lightgrey)](https://swift.org)
[![Test](https://github.com/tdeleon/Relax/workflows/Test/badge.svg?branch=master)](https://github.com/tdeleon/Relax/actions?query=workflow%3ATest)


_A Protocol-Oriented Swift library for building REST client requests_

## Overview

Relax is a client library for defining REST services and requests, built on the concept of [_Protocol Oriented Programming_](https://developer.apple.com/videos/play/wwdc2015/408/). This means that it is largely built with protocols, allowing
for a great deal of flexibility in it's use.

### Reference Documentation
[https://tdeleon.github.io/Relax/](https://tdeleon.github.io/Relax/)

### Features

- **Lightweight & Simple**:  based on protocols, works directly on URLSession for best performance and low overhead
- **Customizable**: Allows for customization when desired (specify your own URLSession; manually `resume()` or `cancel()` URLSessionTasks as needed)
- **Structured**: Helps organize complex REST API requests
- Support for Combine (on available platforms)

### Platforms

Relax is available on all Swift supported platforms, including:
- macOS
- iOS
- tvOS
- watchOS
- Linux

## Getting Started

### Adding to a Project
Relax can be added to projects using the Swift Package Manager, or added as a git submodule.

#### Swift Package Manager
In _Package.swift_:

1. Add to the package dependencies array

    ```
    dependencies: [
        .package(url: "https://github.com/tdeleon/Relax.git", from: "1.0.0")
    ]
    ```
    
2. Add _Relax_ to your target's dependencies array

    ```
    targets: [
        .target(
            name: "YourProject",
            dependencies: ["Relax"])
    ]
    ```

### Usage

Import the Relax framework where it will be used
```
import Relax
```

## Concepts

The Relax framework comprises mainly of two protocols- `Service` and `ServiceRequest`. They can be implemented as structs or classes,
whichever fits better with your use case. Most often you will want to use structs to define services and requests (due to the value semantics and immutabilty), but there is no requirement to do so. For more general information on the differences between structs and classes in Swift, see
[the official Swift documentation](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html).

### Service

The `Service` protocol represents a REST API service that you will make requests to. Each service has a distinct base URL, and all requests
made to the service will use this base URL. Use services to logically group requests together for better organization and code reusability.

> **Note:** For implementing dynamic base URLs (such as with different environments like Dev, Stage, Prod, etc), 
> it is not necessary to define multiple services.

This protocol only has two properties- `Service.baseURL` and `Service.session`. The `baseURL` property is required to be implemented, and 
provides the base URL used for all requests. The `session` property is a `URLSession` instance which requests to this service will be made with. 
This property has a default implementation of  `URLSession.shared`, but you can override this with your own. Additionally, when making 
requests, a session may be passed in to override for a per request.

### ServiceRequest

The `ServiceRequest` protocol represents HTTP requests made against  a `Service`.  Requests can be any of the `HTTPRequestMethod` types. 
The `ServiceRequest.httpMethod` is the only property that you must provide a value for- all others provide a default implementation.

Requests can be customized with:

* Path components - see `ServiceRequest.pathComponents`.
* Query parameters - see `ServiceRequest.queryParameters`.
* Headers - see `ServiceRequest.headers`.
* Content type (this value will be added to the `URLRequest.allHTTPHeaders` field) - see `ServiceRequest.contentType`.
* Request body - see `ServiceRequest.body`.

To make a request, simply call the `request()` method on the `Service`. There are two versions of this method, one using a completion closure,
and another which returns a Combine publisher (available on platforms where Combine is supported). For more details, see `Service.request(_:session:autoResumeTask:completion:)` or `Service.request(_:session:)`. 

## Examples

### Basic

As a minimum, a request only needs the `HTTPRequestMethod` defined. For example:
```
struct ExampleService: Service {
   let baseURL: URL = URL(string: "https://example.com/api/")!
   
   struct Get: ServiceRequest {
      let httpMethod: HTTPRequestMethod = .get
   }
}

ExampleService().request(ExampleService.Get()) { response in
   ...
}
```

### Dynamic Base URLs

```
struct ExampleService: Service {
    var baseURL: URL
    
    struct Get: ServiceRequest {
       let httpMethod: HTTPRequestMethod = .get
    } 
}

let devURL = URL(string: "https://dev.example.com/")!

ExampleService(baseURL: devURL).request(MyRequest()) { response in
    ...
}
```

### Paths

```
struct ExampleService: Service {
    let baseURL: URL = URL(string: "https://example.com/api/")!
   
    // Get request at /products
    struct GetProducts: ServiceRequest {
       let httpMethod: HTTPRequestMethod = .get
       var productID: String
       var queryParameters: [String] {
          return ["products", productID]
       }
    }
}

// Request product with ID "123" - URL: https://example.com/api/products/123
ExampleService().request(ExampleService.GetProducts(productID: "123")) { response in
    ...
}
```

### Grouping Requests

```
struct ExampleService: Service {
    let baseURL: URL = URL(string: "https://example.com/api/")!
    
    struct Customer {
        static let basePath = "customer"
        
        // Get customer by customer ID
        struct Get: ServiceRequest {
            let httpMethod: HTTPRequestMethod = .get
            
            var customerID: String
            var pathComponents: [String] {
                return [Customer.basePath, customerID]
            }
        }
        
        // Add new customer with customer ID, name
        struct Add: ServiceRequest {
            let httpMethod: HTTPRequestMethod = .post
            let pathComponents: [String] = [Customer.basePath]
           
            var customerID: String
            var name: String
            
            var body: Data? {
                // Create JSON from arguments
                let dictionary = ["id": customerID, "name": name]
                return try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            }
        }
    }
}

// Add customer with name "First Last" and ID "123"
ExampleService().request(ExampleService.Customer.Add(customerID: "123", name: "First Last")) { response in
    ...
}

// Request customer with ID "123"
ExampleService().request(ExampleService.Customer.Get(customerID: "123")) { response in
    ...
}
```
### Adding Convenience Methods

```
struct ExampleService: Service {
    let baseURL: URL = URL(string: "https://example.com/api/")!
    
    struct Customer {
        static let basePath = "customer"
        
        // Convenience method to add customer
        static func add(id: String, name: String) {
            let request = ExampleService.Customer.Add(customerID: id, name: name)
            ExampleService().request(request) { response in
                // handle response here
                ...
            }
        }
        
        // Add new customer with customer ID, name
        struct Add: ServiceRequest {
            let httpMethod: HTTPRequestMethod = .post
            let pathComponents: [String] = [Customer.basePath]
           
            var customerID: String
            var name: String
            
            var body: Data? {
                // Create JSON from arguments
                let dictionary = ["id": customerID, "name": name]
                return try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            }
        }
    }
}

// Add customer with name "First Last" and ID "123"
ExampleService.Customer.add(id: "123, name: "First Last")
```

### Using Combine

#### Service Definition

```
struct ExampleService: Service {
    let baseURL: URL = URL(string: "https://example.com/api/")!
    
    struct Customer {
        static let basePath = "customer"
        
        struct Response: Codable {
            let name: String
            let customerID: String
        }
        
        // Get customer by customer ID
        struct Get: ServiceRequest {
            let httpMethod: HTTPRequestMethod = .get
            
            var customerID: String
            var pathComponents: [String] {
                return [Customer.basePath, customerID]
            }
        }
        
        // Add new customer with customer ID, name
        struct Add: ServiceRequest {
            let httpMethod: HTTPRequestMethod = .post
            let pathComponents: [String] = [Customer.basePath]
           
            var customerID: String
            var name: String
            
            var body: Data? {
                // Create JSON from arguments
                let dictionary = ["id": customerID, "name": name]
                return try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            }
        }
    }
}
```

#### Making a Request

```
cancellable = ExampleService().request(ExampleService.Customer.Get())
    .map { $0.data }
    .decode(type: ExampleService.Customer.Response.self, decoder: JSONDecoder())
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            debugPrint("Received error: \(error)")
        }

    }, receiveValue: { product in
        debugPrint("Received product: \(product)")
    })
```
