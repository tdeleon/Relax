//
//  ServiceRequest.swift
//  
//
//  Created by Thomas De Leon on 5/12/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

//MARK: - Defining Requests

/**
 A protocol used to group `ServiceRequest`s with a common path.
 
 If you have multiple requests which share a common path (or other properties), use an `Endpoint` to group them.
 When you set the `ServiceRequest.endpoint` property to the endpoint type, the `Endpoint.path`
 property will automatically be used as the base path for the request (without needing to include it in the
 `ServiceRequest.pathComponents` property).
 
 For example, if you have an endpoint `/users`, with a full url of `https://example.com/api/users`,
 you can define your API as follows:
 
```
 struct Example: Service {
    static let baseURL = URL(string: "https://example.com/api")!
    enum Users: Endpoint {
        static let path = "users"
 
        struct Get: ServiceRequest {
            let endpoint = Users.self
            let httpMethod = .get

            var userID: String?
            // The endpoint path "users" does not need to be specified here
            var pathComponents: [String] {
                [userID].compactMap { $0 }
            }
        }

        struct Add: ServiceRequest {
            let endpoint = Users.self
            let httpMethod = .post

            let userID: String
            let name: String

            var body: Data? {
                // Create JSON from arguments
                let dictionary = ["id": userID, "name": name]
                return try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            }
        }
    }
 }
```
 Note how the endpoint path of `users` does not need to be specified in the Get requests `pathComponents` property.

 The above allows get requests to be made by specifying a specific userID, or fetching all users:
 ```
 do {
    // Fetch all users
    // GET: https://example.com/api/users
    let allUsers: (request, response, data) = try await Example().request(Example.Users.Get())
    // Fetch user 123
    // GET: https://example.com/api/users/123
    let user123: (request, response, data) = try await Example().request(Example.Users.Get(userID: "123"))
 } catch {
     print("Request failed with error- \(error)")
 }
 ```
 We have defined the POST method on the `users` endpoint for adding users:
 ```
 do {
    // Fetch all users
    // POST: https://example.com/api/users
    try await Example().request(Example.Users.Add(userID: "456", name: "Someone"))
 } catch {
     print("Request failed with error- \(error)")
 }
 ```
 
 //TODO: remove
 */
//public protocol Endpoint {
//    /// Common end path for all requests within an `Endpoint`
//    ///
//    /// This component is to be appended to the `Service.baseURL`. For example,
//    /// _https://example/com/api/customers_, where _customers_ is the
//    /// endpoint path, and _https://example.com/api_ is the base URL.
//    static var path: String { get }
//}

//public protocol ServiceRequestDecodable: ServiceRequest {
//    associatedtype ResponseModel: Decodable
//    var decoder: JSONDecoder { get }
//}
//
//extension ServiceRequestDecodable {
//    public var decoder: JSONDecoder { JSONDecoder() }
//}
//
//public protocol ServiceRequestEncodable: ServiceRequest {
//    associatedtype RequestModel: Encodable
//    var encoder: JSONEncoder { get }
//    var requestModel: RequestModel { get }
//}
//
//extension ServiceRequestEncodable {
//    public var body: Data? {
//        try? encoder.encode(requestModel)
//    }
//}
//
//public protocol ServiceRequestCodable: ServiceRequestDecodable, ServiceRequestEncodable {}

/**
 A protocol for requests to be made on a `Service`.
 
 Use this protocol to define requests, which can be any of the `HTTPRequestMethod` types. The `ServiceRequest.httpMethod`
 is the only property that you must provide a value for- all others provide a default implementation.
 
 Requests can be customized with:
 
 * Grouping in an Endpoint - see `ServiceRequest.endpoint`
 * Path components - see `ServiceRequest.pathComponents`.
 * Query parameters - see `ServiceRequest.queryParameters`.
 * Headers - see `ServiceRequest.headers`.
 * Content type (this value will be added to the `URLRequest.allHTTPHeaders` field) - see `ServiceRequest.contentType`.
 * Request body - see `ServiceRequest.body`.
 
 To make a request, simply call the `request()` method on the `Service`. There are three versions of this method:
 
 1. A closure based method which executes the closure on completion of the request - `Service.request(_:session:autoResumeTask:completion:)`.
 2. An asynchronous throwing method using [Swift concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) (_Available when using Swift 5.5 or greater on **Linux**, **iOS 13+**, **watchOS 6+**, **macOS10.15+**, **tvOS 13+**_) - `Service.request(_:session:)`.
 3. A method which returns a [Combine](https://developer.apple.com/documentation/combine) publisher (_available on **iOS 13+**, **watchOS 6+**, **tvOS 13+**, **macOS 10.15**_) - `Service.requestPublisher(_:session:)`.
 
 */
//public protocol ServiceRequest {
//    
//    //MARK: - Properties
//    
//    /// The endpoint this request is associated with
//    /// - SeeAlso: `Endpoint.path`
//    var endpoint: Endpoint.Type? { get }
//    
//    /// The type of request
//    var httpMethod: HTTPRequestMethod { get }
//    /**
//     Path components of the request will be appended to the base URL.
//    
//     Array elements are separated by a `/` in the final request URL. Defaults to an empty array (no parameters).
//    
//     - Note: If an `endpoint` is specified, the `Endpoint.path` value will be automatically set as the first path item
//            before any values specified here. In this case, do not add the endpoint path to the `pathComponents`
//            or it will be duplicated.
//    
//     - SeeAlso: `Service.baseURL`, `endpoint`
//     */
//    var pathComponents: [String] { get }
//    /// Query parameters of the request. Default is an empty array (no parameters)
//    var queryParameters: [URLQueryItem] { get }
//    /**
//     HTTP headers of the request. Default is an empty array (no headers)
//     
//     - Note: Do not set `Content-Type` header field values here; instead use the `contentType` property. The contents of that
//     property will be added to the `URLRequest.allHTTPHeaderFields` property.
//    */
//    var headers: [String: String] { get }
//    /// The content type of the request. The default is `application/json`.
//    /// - Note: This value is added as an HTTP header on the URLRequest.
//    var contentType: RequestContentType? { get }
//    /// Body of the request
//    var body: Data? { get }
//    
//}
//
//public extension ServiceRequest {
//    
//    var endpoint: Endpoint.Type? {
//        return nil
//    }
//    
//    /// No path components (only the `Service.baseURL` will be used).
//    var pathComponents: [String] {
//        return [String]()
//    }
//    
//    /// No query parameters
//    var queryParameters: [URLQueryItem] {
//        return [URLQueryItem]()
//    }
//    
//    /// An empty dictionary
//    var headers: [String: String] {
//        return [String: String]()
//    }
//    
//    /// Returns `RequestContentType.applicationJSON`
//    var contentType: RequestContentType? {
//        return .applicationJSON
//    }
//    
//    /// Returns `nil`.
//    var body: Data? {
//        return nil
//    }
//    
//}

/// A struct representing request content types
///
/// Additional content types may be added as needed.
public struct RequestContentType: RawRepresentable, Hashable {
    /// 
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var rawValue: String
    
    /// Content type of `application/json`
    public static let applicationJSON = RequestContentType("application/json")
    /// Content type of `text/plain`
    public static let textPlain = RequestContentType("text/plain")
    
}

/// HTTP Request type
public enum HTTPRequestMethod: String, Hashable {
    /// `GET` request type
    case get = "GET"
    /// `POST` request type
    case post = "POST"
    /// `PUT` request type
    case put = "PUT"
    /// `PATCH` request type
    case patch = "PATCH"
    /// `DELETE` request type
    case delete = "DELETE"
}
