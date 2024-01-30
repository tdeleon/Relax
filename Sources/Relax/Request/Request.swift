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
public struct Request {
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
    /// This value will be inherited from the parent ``APIComponent/configuration-5p4i`` property, if the request is linked to a parent. If there is no
    /// parent, the default value is ``Request/Configuration-swift.struct/default``.
    public var configuration: Configuration
    
    /// The URLSession to use for this request
    ///
    /// This value will be inherited from the parent ``APIComponent/session-3qjsw`` property, if the request is linked to a parent. If there is no parent, the
    /// default value is `URLSession.shared`.
    ///
    /// - Tip: The session can also be overridden when sending requests.
    public var session: URLSession
    
    /// The decoder to use for this request
    ///
    /// This value will be inherited from the parent ``APIComponent/decoder-bxgv`` property, if the request is linked to a parent. If there is no parent, the
    /// default value is `JSONEncoder()`.
    ///
    /// - Tip: The decoder can also be overridden when sending requests.
    public var decoder: JSONDecoder
    
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
        
        // configuration properties
        request.allowsCellularAccess = configuration.allowsCellularAccess
        request.cachePolicy = configuration.cachePolicy
        request.httpShouldUsePipelining = configuration.httpShouldUsePipelining
        request.networkServiceType = configuration.networkServiceType
        request.timeoutInterval = configuration.timeoutInterval
        request.httpShouldHandleCookies = configuration.httpShouldHandleCookies
        
        // properties not available in FoundationNetworking (non-Apple)
        #if !canImport(FoundationNetworking)
        request.allowsConstrainedNetworkAccess = configuration.allowsConstrainedNetworkAccess
        request.allowsExpensiveNetworkAccess = configuration.allowsExpensiveNetworkAccess
        #endif
        
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
    ///   - session: The session to use for the request. The default is `URLSession.shared`
    ///   - decoder: The decoder to use for the request when receiving data. The default is `JSONDecoder()`.
    ///   - properties: Any additional properties to use in the request, such as the body, headers, query items, or path components. The default value is
    ///   ``Request/Properties/empty`` (no properties).
    public init(
        _ httpMethod: HTTPMethod,
        url: URL,
        configuration: Configuration = .default,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        @Request.Properties.Builder properties: () -> Request.Properties = { .empty }
    ) {
        self.init(
            httpMethod: httpMethod,
            url: url,
            configuration: configuration,
            sesssion: session,
            decoder: decoder,
            properties: properties()
        )
    }
    
    /// Creates a request using a provided HTTP method, using the base URL, configuration, and any shared properties provided by a parent ``APIComponent``
    /// and its' parents. Properties are provided with a ``Request/Properties/Builder``.
    /// - Parameters:
    ///   - httpMethod: The HTTP method for the request
    ///   - parent: A parent which provides various attributes that the request inherits from.
    ///   - configuration: An optional configuration to override what is provided by the parent.
    ///   - session: Overrides the ``APIComponent/session-3qjsw`` provided by the parent.
    ///   - decoder: Overrides the ``APIComponent/decoder-bxgv`` provided by the parent.
    ///   - properties: A ``Request/Properties/Builder`` closure which provides properties to use in this request. The default value is
    ///   ``Request/Properties/empty`` (no properties).
    ///
    ///   - Note: Any `properties` provided are appended to the ``APIComponent/allProperties-7xy23`` defined on the parent, not replaced.
    ///
    /// The request will inherit attributes defined on the `parent`, including:
    /// * ``APIComponent/baseURL``
    /// * ``APIComponent/configuration-5p4i``
    /// * ``APIComponent/session-36tuc``
    /// * ``APIComponent/decoder-74ja3``
    /// * ``APIComponent/allProperties-7xy23``
    ///
    /// You can override any of the above attributes (except for the `baseURL` and `allProperties`) by passing in the corresponding parameters to this
    /// method.
    ///
    public init(
        _ httpMethod: HTTPMethod,
        parent: APIComponent.Type,
        configuration: Configuration? = nil,
        session: URLSession? = nil,
        decoder: JSONDecoder? = nil,
        @Request.Properties.Builder properties: () -> Request.Properties = { .empty }
    ) {
        self.init(
            httpMethod: httpMethod,
            url: parent.baseURL,
            configuration: configuration ?? parent.configuration,
            sesssion: session ?? parent.session,
            decoder: decoder ?? parent.decoder,
            properties: parent.allProperties + properties()
        )
    }
    
    internal init(
        httpMethod: HTTPMethod,
        url: URL,
        configuration: Configuration,
        sesssion: URLSession,
        decoder: JSONDecoder,
        properties: Properties
    ) {
        self._url = url
        
        self.httpMethod = httpMethod
        self.configuration = configuration
        self.session = sesssion
        self.decoder = decoder
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

// JSONEncoder/JSONDecoder are not Hashable, so leave it out of the conformance
extension Request: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_properties)
        hasher.combine(configuration)
        hasher.combine(httpMethod)
        hasher.combine(url)
        hasher.combine(session)
    }
}

// JSONEncoder/JSONDecoder are not Equatable, so leave it out of the conformance
extension Request: Equatable {
    public static func == (lhs: Request, rhs: Request) -> Bool {
        lhs._properties == rhs._properties &&
        lhs.configuration == rhs.configuration &&
        lhs.httpMethod == rhs.httpMethod &&
        lhs.url == rhs.url &&
        lhs.session == rhs.session
    }
}

