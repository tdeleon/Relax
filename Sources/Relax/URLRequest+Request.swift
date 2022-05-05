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
                                          endpointPath: request.endpoint?.path,
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
          endpointPath: String? = nil,
          pathComponents: [String] = [String](),
          queryParameters: [URLQueryItem] = [URLQueryItem](),
          headers: [String: String] = [String: String](),
          contentType: RequestContentType? = .applicationJSON,
          body: Data? = nil) {
        
        var pathString = ""
        var fullPathComponents = [String]()
        
        // check for an endpoint path
        if let endpointPath = endpointPath,
           !endpointPath.isEmpty {
            fullPathComponents.append(contentsOf: endpointPath.components(separatedBy: "/").filter({!$0.isEmpty}))
        }
        
        // add path components
        fullPathComponents.append(contentsOf: pathComponents)
        
        if !fullPathComponents.isEmpty {
            let pathParameterString = fullPathComponents.joined(separator: "/")
            pathString += pathParameterString
        }
        
        // create url components
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            return nil
        }
    
        // set path
        if components.path.last != "/" && !pathString.isEmpty {
            pathString = "/" + pathString
        }
        components.path += pathString
        
        // query parameters
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
        
        // create url request
        self = URLRequest(url: fullURL)
        // set method
        self.httpMethod = type.rawValue
        // set content type
        if let contentType = contentType {
            self.addValue(contentType.rawValue, forHTTPHeaderField: Self.contentTypeHeaderField)
        }
        // add headers
        headers.forEach { self.addValue($0.value, forHTTPHeaderField: $0.key) }
        // set body
        self.httpBody = body
    }
}
