//
//  URLRequest+Request.swift
//
//
//  Created by Thomas De Leon on 5/12/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal extension URLRequest {
    static let contentTypeHeaderField = "Content-Type"
    
    init?<Request: ServiceRequest>(request: Request, baseURL: URL) {
        guard let urlRequest = URLRequest(type: request.httpMethod,
                                          baseURL: baseURL,
                                          pathComponents: request.pathComponents,
                                          queryParameters: request.queryParameters,
                                          headers: request.headers,
                                          contentType: request.contentType,
                                          body: request.body) else {
                                            return nil
        }
        
        self = urlRequest
    }
    
    init?(type: HTTPRequestMethod,
          baseURL: URL,
          pathComponents: [String] = [String](),
          queryParameters: [URLQueryItem] = [URLQueryItem](),
          headers: [String: String] = [String: String](),
          contentType: RequestContentType? = .applicationJSON,
          body: Data? = nil) {
        
        var pathString = ""
        
        if !pathComponents.isEmpty {
            let pathParameterString = pathComponents.joined(separator: "/")
            pathString += "/\(pathParameterString)"
        }
        
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        components.path += pathString
        
        if queryParameters.count > 0 {
            var queryToAdd = queryParameters
            if let existingQuery = components.queryItems {
                queryToAdd = existingQuery + queryToAdd
            }
            components.queryItems = queryToAdd
        }
        
        guard let fullURL = components.url else {
            return nil
        }
        
        self = URLRequest(url: fullURL)
        
        self.httpMethod = type.rawValue
        
        if let contentType = contentType {
            self.addValue(contentType.rawValue, forHTTPHeaderField: Self.contentTypeHeaderField)
        }
        
        headers.forEach { self.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        self.httpBody = body
    }
}
