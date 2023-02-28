//
//  Request.swift
//  
//
//  Created by Thomas De Leon on 7/18/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A structure representing an HTTP request to a REST API
///
/// Requests are created with zero or more properties (``RequestProperty``), and are then sent to a server which provides a response.
///
/// ```swift
/// // Simple GET request to a URL
/// let request = Request(.get, url: URL(string: "https://example.com/")!)
/// ```
///
/// When reuqests are nested as part of an ``APIComponent`` (``Service`` or ``Endpoint``), you specify the `Parent` type to the initializer or
/// ``RequestBuilder`` result builder. In the following example, both `request1` and `request2` are equivalent:
///
/// ```swift
/// enum MyService: Service {
///     static let baseURL = URL(string: https://example.com/)!
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
/// > Tip: For more details, see <doc:DefiningAPIStructure>, <doc:DefiningRequests>, and <doc:SendingRequestsAsync>, <doc:SendingRequestsPublisher>, or <doc:SendingRequestsHandler>.
///
public struct Request: Hashable {    
    /// The HTTP method of the request
    public var httpMethod: HTTPMethod
    
    /// The HTTP headers of the request
    public internal(set) var headers: [String: String] {
        get {
            _properties.headers.value
        }
        set {
            _properties.headers = .init(value: newValue)
        }
    }
    
    /// The query items of the request
    public internal(set) var queryItems: [URLQueryItem] {
        get {
            _properties.queryItems.value
        }
        set {
            _properties.queryItems = .init(value: newValue)
        }
    }
    
    /// The path components of the request
    ///
    /// Components will be appended to the ``APIComponent/baseURL``, before any query items. Each
    /// string in the array will be separated with a `/` character when added to the URL.
    ///
    /// - Note: Invalid URL characters will automatically be escaped when creating the final URL for the request.
    /// This property will show components as they were provided, without escaping.
    public internal(set) var pathComponents: [String] {
        get {
            _properties.pathComponents.value
        }
        set {
            _properties.pathComponents = .init(value: newValue)
        }
    }

    /// The request body
    public internal(set) var body: Data? {
        get {
            _properties.body.value
        }
        set {
            _properties.body = .init(value: newValue)
        }
    }
    
    /// The configuration of the request
    ///
    /// The default value is ``Configuration-swift.struct/default``.
    ///
    /// - Note: This value will be inherited by the parent ``APIComponent`` (``Service``/``Endpoint``)
    /// when provided
    public var configuration: Configuration
    
    /// The request URL
    public var url: URL {
        var fullURL = _url
        _properties.pathComponents.value.forEach { fullURL.appendPathComponent($0) }
        if configuration.appendTraillingSlashToPath {
            fullURL.appendPathComponent("/")
        }
        guard var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: true) else { return _url }
        if !_properties.queryItems.value.isEmpty {
            components.queryItems = _properties.queryItems.value
        }
            
        return components.url ?? _url
    }
    
    /// The URLRequest of the request
    public var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        _properties.headers.value.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = _properties.body.value
        
        request.allowsCellularAccess = configuration.allowsCellularAccess
        request.cachePolicy = configuration.cachePolicy
        request.httpShouldUsePipelining = configuration.httpShouldUsePipelining
        request.networkServiceType = configuration.networkServiceType
        request.timeoutInterval = configuration.timeoutInterval
        request.httpShouldHandleCookies = configuration.httpShouldHandleCookies
        
        return request
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
    ///   - properties: Any additional properties to use in the request, such as the body, headers, query items, or path components. The default value is
    ///   ``Request/Properties/empty`` (no properties).
    public init(
        _ httpMethod: HTTPMethod,
        url: URL,
        configuration: Configuration = .default,
        @Request.Properties.Builder properties: () -> Properties = { .empty }
    ) {
        self.init(httpMethod: httpMethod, url: url, configuration: configuration, properties: properties())
    }
    
    /// Creates a request using a provided HTTP method, using the base URL, configuration, and any shared properties provided by a parent ``APIComponent``
    /// and its' parents. Properties are provided with a ``Request/Properties/Builder``.
    /// - Parameters:
    ///   - httpMethod: The HTTP method for the request
    ///   - parent: A parent which provides the base URL, ``Configuration-swift.struct``, and
    ///   ``APIComponent/sharedProperties-5764x``.
    ///   - configuration: An optional configuration to override what is provided by the parent.
    ///   - properties: A ``Request/Properties/Builder`` closure which provides properties to use in this request. Any provided here will be
    ///   appended to any provided by `parent`. The default value is ``Request/Properties/empty`` (no properties).
    public init(
        _ httpMethod: HTTPMethod,
        parent: APIComponent.Type,
        configuration: Configuration? = nil,
        @Request.Properties.Builder properties: () -> Properties = { .empty }
    ) {
        self.init(
            httpMethod: httpMethod,
            url: parent.baseURL,
            configuration: configuration ?? parent.configuration,
            properties: parent.allProperties + properties()
        )
    }
    
    internal init(
        httpMethod: HTTPMethod,
        url: URL,
        configuration: Configuration,
        properties: Properties
    ) {
        self._url = url
        
        self.httpMethod = httpMethod
        self.configuration = configuration
        
        self._properties = properties
    }
}

extension Request {
    /// HTTP Request type
    ///
    /// The main request types are provided (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`); additional ones can be added as static properties in an extension.
    public struct HTTPMethod: RawRepresentable, Hashable {
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }
        
        /// `GET` request type
        public static let get = HTTPMethod("GET")
        /// `POST` request type
        public static let post = HTTPMethod("POST")
        /// `PUT` request type
        public static let put = HTTPMethod("PUT")
        /// `PATCH` request type
        public static let patch = HTTPMethod("PATCH")
        /// `DELETE` request type
        public static let delete = HTTPMethod("DELETE")
    }
}


@resultBuilder
public enum RequestBuilder<Parent: APIComponent> {
    public static func buildBlock(_ httpMethod: Request.HTTPMethod, _ components: any RequestProperty...) -> Request {
        Request(httpMethod, parent: Parent.self) {
            components.reduce(.empty, { $0 + .from($1) })
        }
    }
    
    @available(*, unavailable, message: "First statement of Request.NestedBuilder must be the HTTPMethod type")
    public static func buildBlock(_ components: any RequestProperty...) -> Request {
        fatalError()
    }
    
}

