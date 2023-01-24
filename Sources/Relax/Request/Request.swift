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

public struct Request {
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
    
    public var headers: [String: String] {
        get {
            _properties.headers.baseValue
        }
        set {
            _properties.headers = .init(value: newValue)
        }
    }
    public var queryItems: [URLQueryItem] {
        get {
            _properties.queryItems.baseValue
        }
        set {
            _properties.queryItems = .init(value: newValue)
        }
    }
    public var pathComponents: [String] {
        get {
            _properties.pathComponents.baseValue
        }
        set {
            _properties.pathComponents = .init(value: newValue)
        }
    }
    public var body: Data? {
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
        pathComponents.forEach { fullURL.appendPathComponent($0) }
        guard var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: true) else { return nil }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
            
        return components.url
    }
    
    public var urlRequest: URLRequest? {
        guard let url = url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = body
        
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
        @RequestPropertiesBuilder properties: () -> RequestProperties = { .empty }
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
        @RequestPropertiesBuilder properties: () -> RequestProperties = { .empty }
    ) {
        self.init(
            httpMethod: httpMethod,
            url: parent.baseURL,
            configuration: configuration ?? parent.configuration,
            properties: parent._sharedProperties + properties()
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
    
    /// <#Description#>
    /// - Parameter property: <#property description#>
    mutating func set(_ property: some RequestProperty) {
        _properties = _properties + .from(property)
    }
    
    /// <#Description#>
    /// - Parameter property: <#property description#>
    /// - Returns: <#description#>
    public func setting(_ property: some RequestProperty) -> Request {
        var request = self
        request.set(property)
        return request
    }
    
    /// <#Description#>
    /// - Parameter property: <#property description#>
    mutating func append(_ property: some RequestProperty) {
        _properties = _properties + .from(property)
    }
    
    /// <#Description#>
    /// - Parameter property: <#property description#>
    /// - Returns: <#description#>
    public func appending(_ property: some RequestProperty) -> Request {
        var request = self
        request.append(property)
        return request
    }
    
    /// <#Description#>
    /// - Parameter configuration: <#configuration description#>
    /// - Returns: <#description#>
    public func updating(_ configuration: Configuration) -> Request {
        var request = self
        request.configuration = configuration
        return request
    }
}

extension Request {
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - value: <#value description#>
    /// - Returns: <#description#>
    public func settingHeader(name: String, value: String?) -> Request {
        var request = self
        request.headers[name] = value
        return request
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - value: <#value description#>
    /// - Returns: <#description#>
    public func settingHeader(name: Header.Name, value: String?) -> Request {
        settingHeader(name: name.rawValue, value: value)
    }
    
    /// <#Description#>
    /// - Parameter header: <#header description#>
    /// - Returns: <#description#>
    public func appending(header: Header) -> Request {
        appendingHeader(name: header.name, value: header.value)
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - value: <#value description#>
    /// - Returns: <#description#>
    public func appendingHeader(name: String, value: String) -> Request {
        var request = self
        request.headers = request.headers.mergingCommaSeparatedValues([name: value])
        return request
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - value: <#value description#>
    /// - Returns: <#description#>
    public func appendingHeader(name: Header.Name, value: String) -> Request {
        appendingHeader(name: name.rawValue, value: value)
    }
    
    /// <#Description#>
    /// - Parameter name: <#name description#>
    /// - Returns: <#description#>
    public func removingHeader(_ name: String) -> Request {
        settingHeader(name: name, value: nil)
    }
    
    /// <#Description#>
    /// - Parameter name: <#name description#>
    /// - Returns: <#description#>
    public func removingHeader(_ name: Header.Name) -> Request {
        removingHeader(name.rawValue)
    }
}

extension Request {
    @discardableResult
    /// <#Description#>
    /// - Parameters:
    ///   - session: <#session description#>
    ///   - autoResumeTask: <#autoResumeTask description#>
    ///   - parseHTTPStatusErrors: <#parseHTTPStatusErrors description#>
    ///   - completion: <#completion description#>
    /// - Returns: <#description#>
    func send(
        session: URLSession = .shared,
        autoResumeTask: Bool = true,
        parseHTTPStatusErrors: Bool = false,
        completion: @escaping Request.Completion
    ) -> URLSessionDataTask? {
        guard let urlRequest else { return nil }
        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard error == nil,
                  let data = data else {
                // Check for URLErrors
                if let urlError = error as? URLError {
                    return completion(.failure(.urlError(request: self, error: urlError)))
                }
                // Any other error
                return completion(.failure(.other(request: self, message: error!.localizedDescription)))
            }
            
            // Check for an HTTPURLResponse
            guard let response = response,
                  let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.urlError(request: self, error: URLError(.unknown))))
            }
            
            let requestResponse = (self, httpResponse, data)
            
            // Check for http status code errors (4xx-5xx series)
            if parseHTTPStatusErrors,
               let httpError = HTTPError(response: requestResponse) {
                completion(.failure(RequestError.httpStatus(request: self, error: httpError)))
            }
            // Success
            else {
                completion(.success(requestResponse))
            }
        }
        
        if autoResumeTask {
            task.resume()
        }
        
        return task
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - decoder: <#decoder description#>
    ///   - session: <#session description#>
    ///   - autoResumeTask: <#autoResumeTask description#>
    ///   - parseHTTPStatusErrors: <#parseHTTPStatusErrors description#>
    ///   - completion: <#completion description#>
    func send<ResponseModel: Decodable>(
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession = .shared,
        autoResumeTask: Bool = true,
        parseHTTPStatusErrors: Bool = false,
        completion: @escaping Request.ModelCompletion<ResponseModel>
    ) {
        send(
            session: session,
            autoResumeTask: autoResumeTask,
            parseHTTPStatusErrors: parseHTTPStatusErrors
        ) { result in
            do {
                let success = try result.get()
                let decoded = try decoder.decode(ResponseModel.self, from: success.data)
                completion(.success((self, success.response, decoded)))
            } catch let error as DecodingError {
                completion(.failure(.decoding(request: self, error: error)))
            } catch let error as RequestError {
                completion(.failure(error))
            } catch {
                completion(.failure(.other(request: self, message: error.localizedDescription)))
            }
        }
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
        Request(
            httpMethod: httpMethod,
            url: Parent.baseURL,
            configuration: Parent.configuration,
            properties: components.reduce(RequestProperties.empty, { $0 + RequestProperties.from($1) })
        )
    }
    
    public static func buildOptional(_ component: Request?) -> Request {
        component ?? Request(.get, parent: Parent.self) { .empty }
    }
    
    public static func buildEither(first component: Request) -> Request {
        component
    }
    
    public static func buildEither(second component: Request) -> Request {
        component
    }
    
    @available(*, unavailable, message: "First statement of Request.NestedBuilder must be the HTTPMethod type")
    static func buildBlock(_ components: any RequestProperty...) -> Request {
        fatalError()
    }
    
}

