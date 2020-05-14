//
//  RelaxRequest.swift
//  
//
//  Created by Thomas De Leon on 5/12/20.
//

import Foundation

/// <#Description#>
public protocol RelaxRequest {
    /// The base URL of the service request is being made
    var baseURL: URL { get }
    /// The type of request
    var requestType: RelaxHTTPRequestType { get }
    /// The endpoint the request is made at
    var endpoint: RelaxEndpoint { get }
    /// Path parameters of the request. Array elements are separated by a `/` in the final request URL. Defaults to an empty array (no parameters).
    var pathParameters: [String] { get }
    /// Query parameters of the request. Default is an empty array (no parameters)
    var queryParameters: [URLQueryItem] { get }
    /// HTTP headers of the request. Default is an empty array (no headers)
    /// - Note: Do not set `Content-Type` header field values here; instead use the `contentType` property. The contents of that property will be added to the `URLRequest.allHTTPHeaderFields` property.
    var headers: [String: String] { get }
    /// The content type of the request. Default value is `application/json`.
    /// - Note: This value is added as an HTTP header on the URLRequest.
    var contentType: RelaxRequestContentType? { get }
    /// Body of the request
    var body: Data? { get }
    
}

public extension RelaxRequest {
    var baseURL: URL {
        return endpoint.service.baseURL
    }
    
    var pathParameters: [String] {
        return [String]()
    }
    
    var queryParameters: [URLQueryItem] {
        return [URLQueryItem]()
    }
    
    var headers: [String: String] {
        return [String: String]()
    }
    
    var contentType: RelaxRequestContentType? {
        return .applicationJSON
    }
    
    var body: Data? {
        return nil
    }
    
    /// The `URLRequest` object representing this request
    var urlRequest: URLRequest? {
        return URLRequest(request: self)
    }
    
    func isEqual(to request: RelaxRequest) -> Bool {
        return self.urlRequest == request.urlRequest
    }
}

/// A struct representing request content types
///
/// Additional content types may be added as needed.
public struct RelaxRequestContentType: RawRepresentable, Hashable {
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var rawValue: String
    
    /// Content type of `application/json`
    public static let applicationJSON = RelaxRequestContentType("application/json")
    /// Content type of `text/plain`
    public static let textPlain = RelaxRequestContentType("text/plain")
    
}

/// HTTP Request type
public enum RelaxHTTPRequestType: String, Hashable {
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
