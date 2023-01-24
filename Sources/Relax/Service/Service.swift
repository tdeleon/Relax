//
//  Service.swift
//
//
//  Created by Thomas De Leon on 5/12/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(Combine)
import Combine
#endif

public protocol BaseURLProviding {
    /// The base URL to use for requests.
    ///
    /// This value is only a base and does not include any values provided by RequestProperties, such as `URLQueryItem`.
    static var baseURL: URL { get }
}

public protocol RequestPropertyProviding {
    /// Properties to be used by all child Requests.
    ///
    /// Any properties defined on an `APIComponentSubItem` or `Request` will override, or, if the property is an `AppendableRequestProperty`,
    /// append to those defined here.
    @RequestPropertiesBuilder static var sharedProperties: RequestProperties { get }
}

public protocol RequestConfigurationProviding {
    static var configuration: Request.Configuration { get }
}

extension RequestConfigurationProviding {
    static var configuration: Request.Configuration { .default }
}

/// A component of an API
public protocol APIComponent: BaseURLProviding, RequestPropertyProviding, RequestConfigurationProviding {}

extension RequestPropertyProviding {
    @RequestPropertiesBuilder
    public static var sharedProperties: RequestProperties { RequestProperties.empty }
    
    internal static var _sharedProperties: RequestProperties { sharedProperties }
}

/// A nested component of an API, which inherits properties and a base URL from it's Parent.
public protocol APIComponentSubItem<Parent>: APIComponent {
    /// The parent component for this item
    associatedtype Parent: APIComponent
}

extension APIComponentSubItem {
    internal static var _sharedProperties: RequestProperties {
        Parent._sharedProperties + sharedProperties
    }
}

/**
 A protocol to define a REST API service

 To define a service, implement the `Service` protocol. Each service has a distinct base URL, and all requests made
 to the service will use this base URL. Use services to logically group requests together for better organization and code
 reusability.

 - Note: For implementing dynamic base URLs (such as with different environments like Dev, Stage, Prod, etc), it is not necessary to define multiple services.

 #### About the protocol
 This protocol only has two properties- `Service.baseURL` and `Service.session`. The `baseURL` property is required to be implemented, and provides
 the base URL used for all requests (see [Making Requests](Making%20Requests.html) for more on requests). The `session` property is a
 `URLSession` instance that requests are made using. This property has a default implementation of `URLSession.shared`, but you can override this
 with your own. Additionally, when making requests,  a session may be passed in per request.
 
 - SeeAlso: `Endpoint`, `ServiceRequest`
 
*/
public protocol Service: APIComponent {
    //MARK: - Properties
    /// The base URL of the service. This value is shared among all endpoints on the service.
    static var baseURL: URL { get }
    
    /// The `URLSession` that requests to this service will use.
    ///
    /// The value of this property will be used for all requests made on this service, unless an override
    /// is provided to a given request.
    static var session: URLSession { get }
    
    //MARK: - Handling Responses
    
    /**
     Completion handler based response for an HTTP request
    
     - `request`: The request made
     - `response`: The response received
     - `data`: The data received, if any
     */
    typealias Response = (request: URLRequest, response: HTTPURLResponse, data: Data?)
    
    typealias ResponseModel<Model: Decodable> = (request: URLRequest, response: HTTPURLResponse, responseModel: Model)
    
    /**
     Response for an HTTP request using a Combine publisher
     
        - `request`: The request made
        - `response`: The response received
        - `data`: Data received
     */
    typealias PublisherResponse = (request: URLRequest, response: HTTPURLResponse, data: Data)
    
    typealias PublisherModelResponse<Model: Decodable> = (request: URLRequest, response: HTTPURLResponse, responseModel: Model)
    
    /**
     Response for an async HTTP request
     
        - `request`: The request made
        - `response`: The response received
        - `data`: Data received
     */
    typealias AsyncResponse = (request: URLRequest, response: HTTPURLResponse, data: Data)
    
    typealias AsyncModelResponse<Model: Decodable> = (request: URLRequest, response: HTTPURLResponse, responseModel: Model)
    
    /**
     Completion handler for requests made
     
     - Parameter result: Result receieved
     
     */
    typealias RequestCompletion = (_ result: Result<Response, RequestError>) -> Void
    
    typealias RequestModelCompletion<Model: Decodable> = (_ result: Result<ResponseModel<Model>, RequestError>) -> Void
}

protocol Endpoint: APIComponent, APIComponentSubItem {
    static var path: String { get }
}

extension Endpoint {
    public static var baseURL: URL {
        Parent.baseURL.appendingPathComponent(path)
    }
}

//MARK: - Making Requests
public extension Service {
    static var baseURL: URL { baseURL }
    
    ///  Returns `URLSession.shared`.
    static var session: URLSession { .shared }
}
