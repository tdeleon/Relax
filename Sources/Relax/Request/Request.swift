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

public struct Request: Hashable {
    /**
     Completion handler based response for an HTTP request
    
     - `request`: The request made
     - `response`: The response received
     - `data`: The data received, if any
     */
    public typealias Response = (request: Request, response: HTTPURLResponse, data: Data)
    
    public typealias ResponseModel<Model: Decodable> = (request: Request, response: HTTPURLResponse, responseModel: Model)
    
    /**
     Completion handler for requests made
     
     - Parameter result: Result receieved
     
     */
    public typealias Completion = (_ result: Result<Response, RequestError>) -> Void
    
    public typealias ModelCompletion<Model: Decodable> = (_ result: Result<ResponseModel<Model>, RequestError>) -> Void
    
    public var httpMethod: HTTPMethod
    
    public internal(set) var headers: [String: String] {
        get {
            _properties.headers.baseValue
        }
        set {
            _properties.headers = .init(value: newValue)
        }
    }
    
    public internal(set) var queryItems: [URLQueryItem] {
        get {
            _properties.queryItems.baseValue
        }
        set {
            _properties.queryItems = .init(value: newValue)
        }
    }
    
    public internal(set) var pathComponents: [String] {
        get {
            _properties.pathComponents.baseValue
        }
        set {
            _properties.pathComponents = .init(value: newValue)
        }
    }

    public internal(set) var body: Data? {
        get {
            _properties.body.baseValue
        }
        set {
            _properties.body = .init(value: newValue)
        }
    }
    public var configuration: Configuration
    
    internal var _url: URL
    internal var _properties: RequestProperties
    
    public var url: URL? {
        var fullURL = _url
        _properties.pathComponents.baseValue.forEach { fullURL.appendPathComponent($0) }
        guard var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: true) else { return nil }
        if !_properties.queryItems.baseValue.isEmpty {
            components.queryItems = _properties.queryItems.baseValue
        }
            
        return components.url
    }
    
    public var urlRequest: URLRequest? {
        guard let url = url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        _properties.headers.baseValue.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = _properties.body.baseValue
        
        request.allowsCellularAccess = configuration.allowsCellularAccess
        request.cachePolicy = configuration.cachePolicy
        request.httpShouldUsePipelining = configuration.httpShouldUsePipelining
        request.networkServiceType = configuration.networkServiceType
        request.timeoutInterval = configuration.timeoutInterval
        request.httpShouldHandleCookies = configuration.httpShouldHandleCookies
        
        return request
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - httpMethod: <#httpMethod description#>
    ///   - url: <#url description#>
    ///   - configuration: <#configuration description#>
    ///   - properties: <#properties description#>
    public init(
        _ httpMethod: HTTPMethod,
        url: URL,
        configuration: Configuration = .default,
        @RequestProperties.Builder properties: () -> RequestProperties = { .empty }
    ) {
        self.init(httpMethod: httpMethod, url: url, configuration: configuration, properties: properties())
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - httpMethod: <#httpMethod description#>
    ///   - parent: <#parent description#>
    ///   - configuration: <#configuration description#>
    ///   - properties: <#properties description#>
    public init(
        _ httpMethod: HTTPMethod,
        parent: APIComponent.Type,
        configuration: Configuration? = nil,
        @RequestProperties.Builder properties: () -> RequestProperties = { .empty }
    ) {
        self.init(
            httpMethod: httpMethod,
            url: parent.baseURL,
            configuration: configuration ?? parent.configuration,
            properties: parent.allProperties + properties()
        )
    }
    
    public init(_ httpMethod: HTTPMethod, url: URL, configuration: Configuration = .default) {
        self.init(httpMethod: httpMethod, url: url, configuration: configuration, properties: .empty)
    }
    
    internal init(
        httpMethod: HTTPMethod,
        url: URL,
        configuration: Configuration,
        properties: RequestProperties
    ) {
        self._url = url
        
        self.httpMethod = httpMethod
        self.configuration = configuration
        
        self._properties = properties
    }
}



extension Request {
    /// HTTP Request type
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
/// <#Description#>
public enum RequestBuilder<Parent: APIComponent> {
    static func buildBlock(_ httpMethod: Request.HTTPMethod, _ components: any RequestProperty...) -> Request {
        Request(httpMethod, parent: Parent.self) {
            components.reduce(.empty, { $0 + .from($1) })
        }
    }
    
    @available(*, unavailable, message: "First statement of Request.NestedBuilder must be the HTTPMethod type")
    static func buildBlock(_ components: any RequestProperty...) -> Request {
        fatalError()
    }
    
}

