//
//  URLRequest+RelaxRequest.swift
//
//
//  Created by Thomas De Leon on 5/12/20.
//

import Foundation

internal extension URLRequest {
    init?(request: RelaxRequest) {
        guard let urlRequest = URLRequest(type: request.requestType,
                                          baseURL: request.baseURL,
                                          endpoint: request.endpoint.name,
                                          pathParameters: request.pathParameters,
                                          queryParameters: request.queryParameters,
                                          headers: request.headers,
                                          contentType: request.contentType,
                                          body: request.body) else {
                                            return nil
        }
        
        self = urlRequest
    }
    
    init?(type: RelaxHTTPRequestType,
          baseURL: URL,
          endpoint: String? = nil,
          pathParameters: [String] = [String](),
          queryParameters: [URLQueryItem] = [URLQueryItem](),
          headers: [String: String] = [String: String](),
          contentType: RelaxRequestContentType? = .applicationJSON,
          body: Data? = nil) {
        
        var pathString = endpoint ?? ""
        
        if !pathParameters.isEmpty {
            let pathParameterString = pathParameters.joined(separator: "/")
            pathString += "/\(pathParameterString)"
        }
        
        var url = baseURL
        
        if !pathString.isEmpty {
            guard let endpointURL = URL(string: pathString, relativeTo: baseURL) else {
                return nil
            }
            url = endpointURL
        }
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        if queryParameters.count > 0 {
            components.queryItems = queryParameters
        }
        
        guard let fullURL = components.url else {
            return nil
        }
        
        self = URLRequest(url: fullURL)
        
        self.httpMethod = type.rawValue
        
        if let contentType = contentType {
            self.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        headers.forEach { self.addValue($0.value, forHTTPHeaderField: $0.key)}
        
        self.httpBody = body
    }
}
