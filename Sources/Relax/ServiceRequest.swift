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
 A protocol for requests to be made on a `Service`.
 
 Use this protocol to define requests, which can be any of the `HTTPRequestMethod` types. The `ServiceRequest.httpMethod`
 is the only property that you must provide a value for- all others provide a default implementation.
 
 Requests can be customized with:
 
 * Path components - see `ServiceRequest.pathComponents`.
 * Query parameters - see `ServiceRequest.queryParameters`.
 * Headers - see `ServiceRequest.headers`.
 * Content type (this value will be added to the `URLRequest.allHTTPHeaders` field) - see `ServiceRequest.contentType`.
 * Request body - see `ServiceRequest.body`.
 
 To make a request, simply call the `request()` method on the `Service`. There are two versions of this method, one using a completion closure,
 and another which returns a Combine publisher (available on platforms where Combine is supported). For more details, see `Service.request(_:session:autoResumeTask:completion:)` or `Service.request(_:session:)`. 
 */
public protocol ServiceRequest {
    
    //MARK: - Properties
    
    /// The type of request
    var httpMethod: HTTPRequestMethod { get }
    /// Path components of the request will be appended to the base URL.
    ///
    /// Array elements are separated by a `/` in the final request URL. Defaults to an empty array (no parameters).
    ///
    /// #### See Also
    /// `Service.baseURL`
    var pathComponents: [String] { get }
    /// Query parameters of the request. Default is an empty array (no parameters)
    var queryParameters: [URLQueryItem] { get }
    /// HTTP headers of the request. Default is an empty array (no headers)
    ///
    /// - Note: Do not set `Content-Type` header field values here; instead use the `contentType` property. The contents of that
    /// property will be added to the `URLRequest.allHTTPHeaderFields` property.
    var headers: [String: String] { get }
    /// The content type of the request. The default is `application/json`.
    /// - Note: This value is added as an HTTP header on the URLRequest.
    var contentType: RequestContentType? { get }
    /// Body of the request
    var body: Data? { get }
    
}

public extension ServiceRequest {
    
    /// No path components (only the `Service.baseURL` will be used).
    var pathComponents: [String] {
        return [String]()
    }
    
    /// No query parameters
    var queryParameters: [URLQueryItem] {
        return [URLQueryItem]()
    }
    
    /// An empty dictionary
    var headers: [String: String] {
        return [String: String]()
    }
    
    /// Returns `RequestContentType.applicationJSON`
    var contentType: RequestContentType? {
        return .applicationJSON
    }
    
    /// Returns `nil`.
    var body: Data? {
        return nil
    }
    
}

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
