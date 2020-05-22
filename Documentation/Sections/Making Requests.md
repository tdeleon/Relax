### Overview
To make requests, implement the `ServiceRequest` protocol.

#### About the protocol
Use this protocol to define requests, which can be any of the `HTTPRequestMethod` types. The `ServiceRequest.httpMethod`
is the only property that you must provide a value for- all others provide a default implementation.

Requests can be customized with:

* Path components - see `ServiceRequest.pathComponents`.
* Query parameters - see `ServiceRequest.queryParameters`.
* Headers - see `ServiceRequest.headers`.
* Content type (this value will be added to the `URLRequest.allHTTPHeaders` field) - see `ServiceRequest.contentType`.
* Request body - see `ServiceRequest.body`.

#### Making Requests

To make a request, simply call the `request()` method on the `Service`. There are two versions of this method, one using a completion closure,
and another which returns a Combine publisher (available on platforms where Combine is supported). For more details, see `Service.request(_:session:autoResumeTask:completion:)` or `Service.request(_:session:)`. 


### Request Basics

#### Simple Request

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
This will make a GET request at the URL _https://example.com/api/_, with the _Content-Type_ header set to _application/json_.

#### Changing Content-Type

To remove or customize the _Content-Type_ value, simply provide an implementation for the `ServiceRequest.contentType` property:

```
struct Get: ServiceRequest {
   let httpMethod: HTTPRequestMethod = .get
   let contentType: RequestContentType = nil // No Content-Type value will be sent in the header
}
```

### Customizing Requests

Most often, your requests will have more complexity, such as query parameters, path components, or a body. These values may be static, dynamic, or a
combination of both.

#### Providing Static Paths

To provide a static path component for a request, simply implement the `pathComponents` property. This example provides two requests-
* `GetProducts` corresponds to _https://example.com/api/products_
* `GetCustomers` corresponds to _https://example.com/api/customers_

```
struct ExampleService: Service {
   let baseURL: URL = URL(string: "https://example.com/api/")!
   
   // Get request at /products
   struct GetProducts: ServiceRequest {
      let httpMethod: HTTPRequestMethod = .get
      let pathComponents: [String] = ["products"]
   }

   // Get request at /customers
   struct GetCustomers: ServiceRequest {
      let httpMethod: HTTPRequestMethod = .get
      let pathComponents: [String] = ["customers"]
   }
}
```

#### Dynamic Values

For dynamic parameters, you can simply add properties or a function to your concrete type.

For example, fetching products by ID with a dynamic path component.
This example makes the request _https://example.com/api/products/123_.
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

// Request product with ID "123"
ExampleService().request(ExampleService.GetProducts(productID: "123")) { response in
    ...
}
```

Alternatively, you might use a query parameter as opposed to a path parameter.
This example makes the request _https://example.com/api/products?productID=123_
Note that the `pathComponents` value also needs to be provided here, to specify the component _/products_.

```
struct ExampleService: Service {
   let baseURL: URL = URL(string: "https://example.com/api/")!
   
   // Get request at /products
   struct GetProducts: ServiceRequest {
      let httpMethod: HTTPRequestMethod = .get
      let pathComponents: [String] = ["products"]

      var productID: String
      var queryParameters: [String] {
         return ["products", productID]
      }
   }
}

// Request product with ID "123"
ExampleService().request(ExampleService.GetProducts(productID: "123")) { response in
   ...
}
```

### Grouping Common Requests

You may have several requests that all operate on a common path endpoint, and may share properties between them. Instead of repeating these for each
request defined, they can be grouped together. Additionally, this can help organize the code logically so it is easier to read.

For example, on a _/customers_ endpoint, you may have several requests to fetch a customer, update an existing, or add a new one. These can be nested under a common struct, which we will call `Customers`.

```
struct ExampleService: Service {
    let baseURL: URL = URL(string: "https://example.com/api/")!
    
    struct Customers {
        static let basePath = "customers"
        
        // Get customer by customer ID
        struct Get: ServiceRequest {
            let httpMethod: HTTPRequestMethod = .get
            
            var customerID: String
            var pathComponents: [String] {
                return [Customers.basePath, customerID]
            }
        }
        
        // Add new customer with customer ID, name
        struct Add: ServiceRequest {
            let httpMethod: HTTPRequestMethod = .post
            let pathComponents: [String] = [Customers.basePath]
           
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
ExampleService().request(ExampleService.Customers.Add(customerID: "123", name: "First Last")) { response in
    ...
}

// Request customer with ID "123"
ExampleService().request(ExampleService.Customers.Get(customerID: "123")) { response in
    ...
}
```

# Reference
