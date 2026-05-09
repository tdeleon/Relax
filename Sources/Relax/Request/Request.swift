//
//  Request.swift
//  
//
//  Created by Thomas De Leon on 7/18/22.
//

import Foundation
#if canImport(FoundationNetworking)
@preconcurrency import FoundationNetworking
#endif
import HTTPTypes
import HTTPTypesFoundation

/// A structure representing an HTTP request to a REST API
///
/// Requests are created with zero or more properties (``RequestProperty``), and are then sent to a server which provides a response.
///
/// ```swift
/// // Simple GET request to a URL
/// let request = Request(.get, url: URL(string: "https://example.com/")!)
/// ```
///
/// When reuqests are nested as part of an ``APIComponent`` (``Service`` or ``Endpoint``), you specify the ``APISubComponent/Parent``  type to
/// the initializer or ``RequestBuilder`` result builder. In the following example, both `request1` and `request2` are equivalent:
///
/// ```swift
/// enum MyService: Service {
///     static let baseURL = URL(string: "https://example.com/")!
///
///     // Uses the baseURL defined on MyService
///     @RequestBuilder<MyService>
///     static var request1: Request {
///         QueryItems { ("name", "value") }
///     }
///
///     // Uses the baseURL defined on MyService
///     static let request2 = Request(.get, parent: MyService.self) {
///         QueryItems { ("name", "value") }
///     }
/// }
/// ```
///
/// You can add or replace properties after the request is created using modifier style methods before sending them:
/// ```swift
/// let response = try await request
///         .settingHeader(name: "name", value: "value")
///         .send()
/// ```
/// > Tip: For more details, see <doc:DefiningAPIStructure>, <doc:DefiningRequests>, and <doc:SendingRequestsAsync>,
/// <doc:SendingRequestsPublisher>, or <doc:SendingRequestsHandler>.
///
public struct Request: Sendable {
    /// The HTTP method of the request
    public var httpMethod: HTTPRequest.Method
    
    /// The HTTP headers of the request
    public var headers: HTTPFields
    
    /// The query items of the request
    public var queryItems: [URLQueryItem]
    
    /// The path components of the request
    ///
    /// Components will be appended to the ``APIComponent/baseURL``, before any query items. Each
    /// string in the array will be separated with a `/` character when added to the URL.
    ///
    /// - Note: Invalid URL characters will automatically be escaped when creating the final URL for the request.
    /// This property will show components as they were provided, without escaping.
    public var pathComponents: PathComponents

    /// The request body
    public var body: Data?
    
    /// The configuration of the request
    ///
    /// This value will be inherited from the parent ``APIComponent/configuration-5p4i`` property, if the request is linked to a parent. If there is no
    /// parent, the default value is ``Request/Configuration-swift.struct/default``.
    public var configuration: Configuration
    
    /// The request URL
    public var url: URL {
        var fullURL = _url
        fullURL.append(path: pathComponents.description)
        if configuration.appendTraillingSlashToPath {
            fullURL.append(path: "/")
        }
        guard var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: true) else { return _url }
        if !_properties.queryItems._value.isEmpty {
            components.queryItems = _properties.queryItems._value
        }
        
        return components.url ?? _url
    }
    
    /// The URLRequest of the request
    public var urlRequest: URLRequest? {
        URLRequest(httpRequest: httpRequest)
//        var request = URLRequest(url: url)
//        request.httpMethod = httpMethod.rawValue
//        _properties.headers.value.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
//        request.httpBody = _properties.body.value
//        
//        // configuration properties
//        request.allowsCellularAccess = configuration.allowsCellularAccess
//        request.cachePolicy = configuration.cachePolicy
//        request.httpShouldUsePipelining = configuration.httpShouldUsePipelining
//        request.networkServiceType = configuration.networkServiceType
//        request.timeoutInterval = configuration.timeoutInterval
//        request.httpShouldHandleCookies = configuration.httpShouldHandleCookies
//        
//        // properties not available in FoundationNetworking (non-Apple)
//        #if !canImport(FoundationNetworking)
//        request.allowsConstrainedNetworkAccess = configuration.allowsConstrainedNetworkAccess
//        request.allowsExpensiveNetworkAccess = configuration.allowsExpensiveNetworkAccess
//        #endif
//        
//        return request
    }
    
    public var httpRequest: HTTPRequest {
        HTTPRequest(method: httpMethod, url: url, headerFields: headers)
    }
    
//MARK: Internal properties
    
    internal var _url: URL
    internal var _properties: Properties
    
//MARK: - Initializers
    
    /// Creates a request using a provided HTTP method, base URL, and properties using a ``Request/Properties/Builder``.
    /// - Parameters:
    ///   - httpMethod: The HTTP method to use
    ///   - url: The base URL of the request (this does not include path components and query items which you provide in `properties`).
    ///   - configuration: The configuration for the request. The default is ``Configuration-swift.struct/default``.
    ///   - session: The session to use for the request. The default is `URLSession.shared`
    ///   - decoder: The decoder to use for the request when receiving data. The default is `JSONDecoder()`.
    ///   - properties: Any additional properties to use in the request, such as the body, headers, query items, or path components. The default value is
    ///   ``Request/Properties/empty`` (no properties).
    @available(*, deprecated, message: "HTTPMethod is deprecated. Use the initializer with HTTPRequest.Method instead.")
    public init(
        _ httpMethod: HTTPMethod,
        url: URL,
        configuration: Configuration = .default,
        @Request.Properties.Builder properties: () -> Request.Properties = { .empty }
    ) {
        self.init(
            httpMethod: httpMethod.httpRequestMethod ?? .get,
            url: url,
            headers: HTTPFields(),
            configuration: configuration,
            properties: properties()
        )
    }
    
    /// Creates a request using a provided HTTP method, base URL, and properties using a ``Request/Properties/Builder``.
    /// - Parameters:
    ///   - httpMethod: The HTTP method to use
    ///   - url: The base URL of the request (this does not include path components and query items which you provide in `properties`).
    ///   - configuration: The configuration for the request. The default is ``Configuration-swift.struct/default``.
    ///   - properties: Any additional properties to use in the request, such as the body, headers, query items, or path components. The default value is
    ///   ``Request/Properties/empty`` (no properties).
    public init(
        _ httpMethod: HTTPRequest.Method,
        url: URL,
        configuration: Configuration = .default,
        @Request.Properties.Builder properties: () -> Request.Properties = { .empty }
    ) {
        self.init(
            httpMethod: httpMethod,
            url: url,
            headers: HTTPFields(),
            configuration: configuration,
            properties: properties()
        )
    }
    
    internal init(
        httpMethod: HTTPRequest.Method,
        url: URL,
        headers: HTTPFields,
        configuration: Configuration,
        properties: Properties
    ) {
        self._url = url
        
        self.httpMethod = httpMethod
        self.configuration = configuration
        self._properties = properties
        self.headers = headers
        self.queryItems = properties.queryItems._value
        self.headers = properties.headers
        self.pathComponents = properties.pathComponents
        self.body = properties.body.value
    }
}

extension Request {
    /// HTTP Request type
    ///
    /// The main request types are provided (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`); additional ones can be added as static properties in an extension.
    @available(*, deprecated, message: "Use HTTPRequest.Method instead")
    public struct HTTPMethod: RawRepresentable, Hashable, Sendable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
        
        /// `GET` request type
        @available(*, deprecated, message: "Use HTTPRequest.Method.get")
        public static let get = HTTPMethod("GET")
        /// `PUT` request type
        @available(*, deprecated, message: "Use HTTPRequest.Method.put")
        public static let put = HTTPMethod("PUT")
        /// `POST` request type
        @available(*, deprecated, message: "Use HTTPRequest.Method.post")
        public static let post = HTTPMethod("POST")
        /// `DELETE` request type
        @available(*, deprecated, message: "Use HTTPRequest.Method.delete")
        public static let delete = HTTPMethod("DELETE")
        /// `PATCH` request type
        @available(*, deprecated, message: "Use HTTPRequest.Method.patch")
        public static let patch = HTTPMethod("PATCH")
        
        /// A bridge to the standardized HTTPRequest.Method from swift-http-types
        internal var httpRequestMethod: HTTPRequest.Method? {
            HTTPRequest.Method(rawValue)
        }
    }
}


//@resultBuilder
//public enum RequestBuilder<Parent: APIComponent> {
//    public static func buildBlock(_ httpMethod: Request.HTTPMethod, _ components: any RequestProperty...) -> Request {
//        Request(httpMethod, parent: Parent.self) {
//            components.reduce(.empty, { $0 + .from($1) })
//        }
//    }
//    
//    public static func buildBlock(_ httpMethod: HTTPRequest.Method, _ components: any RequestProperty...) -> Request {
//        <#code#>
//    }
//    
//    @available(*, unavailable, message: "First statement of Request.NestedBuilder must be the HTTPMethod type")
//    public static func buildBlock(_ components: any RequestProperty...) -> Request {
//        fatalError()
//    }
//    
//}

// JSONEncoder/JSONDecoder are not Hashable, so leave it out of the conformance
//extension Request: Hashable {
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(_properties)
//        hasher.combine(configuration)
//        hasher.combine(httpMethod)
//        hasher.combine(url)
//    }
//}
//
//// JSONEncoder/JSONDecoder are not Equatable, so leave it out of the conformance
//extension Request: Equatable {
//    public static func == (lhs: Request, rhs: Request) -> Bool {
//        lhs._properties == rhs._properties &&
//        lhs.configuration == rhs.configuration &&
//        lhs.httpMethod == rhs.httpMethod &&
//        lhs.url == rhs.url
//    }
//}

extension Request {
    internal func handleURLSessionResponse(_ response: (Data, URLResponse)) throws -> (Request, HTTPURLResponse, Data) {
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            throw RequestError.urlError(request: self, error: URLError(.unknown))
        }
        let requestResponse = (self, httpResponse, response.0)
        if configuration.parseHTTPStatusErrors,
           let httpError = RequestError.HTTPError(response: requestResponse) {
            throw(RequestError.httpStatus(request: self, error: httpError))
        }
        return requestResponse
    }
}
