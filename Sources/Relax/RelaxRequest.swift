//
//  RelaxRequest.swift
//  
//
//  Created by Thomas De Leon on 5/12/20.
//

import Foundation

public protocol RelaxRequest {
    var baseURL: URL { get }
    
    var requestType: RelaxRequestType { get }
    
    var endpoint: RelaxEndpoint { get }
    
    var pathParameters: [String] { get }
    
    var queryParameters: [URLQueryItem] { get }
    
    var headers: [String: String] { get }
    
    var contentType: RelaxRequestContentType? { get set }
    
    var body: Data? { get set }
    
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
    
    var urlRequest: URLRequest? {
        return URLRequest(request: self)
    }
    
    func isEqual(to request: RelaxRequest) -> Bool {
        return self.urlRequest == request.urlRequest
    }
}

public struct RelaxRequestContentType: RawRepresentable, Hashable {
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var rawValue: String
    
    static let applicationJSON = RelaxRequestContentType("application/json")
    static let textPlain = RelaxRequestContentType("text/plain")
    
}

public enum RelaxRequestType: String, Hashable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
