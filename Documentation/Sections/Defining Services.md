### Overview

To define a service, implement the `Service` protocol. Each service has a distinct base URL, and all requests made
to the service will use this base URL. Use services to logically group requests together for better organization and code
reusability.

> **Note:** For implementing dynamic base URLs (such as with different environments like Dev, Stage, Prod, etc), 
> it is not necessary to define multiple services. See [Dynamic Base URLs](#dynamicURL).

#### About the protocol
This protocol only has two properties- `Service.baseURL` and `Service.session`. The `baseURL` property is required to be
implemented, and provides the base URL used for all requests (see [Making Requests](Making%20Requests.html) for more on requests). The `session` property is a `URLSession` instance that requests are made using. This property has a default implementation of `URLSession.shared`, but you can override this with your own. Additionally, when making requests,
a session may be passed in per request.

### Defining a Service

#### Simple Service

Defining a service is as simple as declaring the base URL:

```
struct ExampleService: Service {
    let baseURL: URL = URL(string: "https://example.com/")!
}
```

#### Customizing URLSession

By overriding the default `Service.session` property, you can use your own instance of `URLSession` instead of the default shared one.

```
struct ExampleService: Service {
    let baseURL: URL = URL(string: "https://example.com/")!
    static var session: URLSession {
        var config = URLSessionConfiguration.default
        config.timeIntervalForRequest = 30
        config.allowsCellularAccess = false
        return URLSession(configuration: config)
    }
}
```
<a name="dynamicURL"></a>

#### Dynamic Base URLs

Often the service will have multiple environments, such as _Dev_, _Stage_, _Prod_, etc. Or, the domain used may be
different per user account or location, not being known until runtime. There are a few ways of handling this.

By not providing an implementation of the `Service.baseURL` property, the base URL must then be provided as an initializer argument each time an instance of the service is created.

```
struct ExampleService: Service {
    var baseURL: URL
}

let devURL = URL(string: "https://dev.example.com/")!

ExampleService(baseURL: devURL).request(MyRequest()) { response in
    ...
}
```
Alternatively, an enum could be used as an initializer argument:
```
struct ExampleService: Service {
    enum Environment {
        case dev, stage, prod
        var url: URL {
            switch self {
            case .dev:
                return URL(string: "https://dev.example.com/")!
            case .stage:
                return URL(string: "https://stage.example.com/")!
            case .prod:
                return URL(string: "https://dev.example.com/")!
            }
        }
    }
    
    let environment: Environment
    
    var baseURL: URL {
        return environment.url
    }
}

ExampleService(environment: .dev).request(MyRequest()) { response in
    ...
}
```
When using compiler flags to determine the current environment:
```
struct ExampleService: Service {
    var baseURL: URL {
    #if DEV
        return URL(string: "https://dev.example.com/")!
    #elseif STAGE
        return URL(string: "https://stage.example.com/")!
    #else
        return URL(string: "https://prod.example.com/")!
    #endif
    }
}


ExampleService().request(MyRequest()) { response in
    ...
}
```

### Making Requests

There are two ways of making requests against a service- a completion closure based method or using a Combine publisher
(on available platforms/OS versions). For either case, a `ServiceRequest` must first be defined to represent the request, and then passed in to `Service.request(_:session:autoResumeTask:completion:)` or `Service.request(_:session:)`
respectively.

#### Defining a Request

> For a more detailed explanation on `ServiceRequest`, see [Making Requests](Making%20Requests.html).

This example defines a `GET` request at the URL _https://example.com/products_:

```
struct ExampleService: Service {
   let baseURL: URL = URL(string: "https://example.com/")!
   
   struct GetProducts: ServiceRequest {
      let requestType: HTTPRequestMethod = .get
      var pathComponents: [String] = ["products"]
   }
}
```

#### Using a Completion Handler

To make the request, pass an instance of the `ServiceRequest` into the
`Service.request(_:session:autoResumeTask:completion:)`:
```
ExampleService().request(ExampleService.GetProducts()) { response in
    switch response {
    case .failure(let error):
        debugPrint("Failed to fetch products - \(error)")
    case .success(let success):
        // handle success response
    }
}
```

This method also returns a discardable result of `URLSessionDataTask`. By default, `resume()` is called on the task to
start the download. If desired, you can manage this yourself by passing in `false` to the `autoResume`, and then calling `resume()` and/or `cancel()` on the returned task.

> **Warning:** If the `autoResume()` parameter is true (the default), **do not** call `resume()` on the returned task, or
> the download will be started multiple times.

```
...
task = ExampleService().request(ExampleService.GetProducts()) { response in
    ...
}

task?.resume()
...
deinit() {
    task?.cancel()
}
```

#### Using Combine

To make the request, pass an instance of the `ServiceRequest` into the `Service.request(_:session:)` method. This 
method returns a publisher of type `AnyPublisher<PublisherResponse<Request>, RequestError>`.

_In this example, assume that there is a Codable object `Product` previously defined._

```
cancellable = ExampleService().request(ExampleService.GetProducts())
    .map { $0.data }
    .decode(type: Product.self, decoder: JSONDecoder())
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

### Errors

Errors are returned as `RequestError` enum cases with associated values. In cases where a request had a problem, the
associated `URLRequest` that was used will be returned as an associated value.

See `RequestError` for details.

# Reference
