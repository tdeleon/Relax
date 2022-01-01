//
//  Service+Async.swift
//  
//
//  Created by Thomas De Leon on 1/1/22.
//

#if !canImport(FoundationNetworking) && swift(>=5.5) // Async has not been implemented in FoundationNetworking (Linux/Windows) yet
import Foundation

extension Service {
    /**
     Make a request asyncrhonously
     - Parameters:
        - request: The request to execute
        - session: The session to use. If not specified, the default provided by the `session` property of the `Service` will be used
     - Returns: A tuple containing the request, response, and data.
     - Throws: A `RequestError` of the error which occurred.
    */
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public func request<Request: ServiceRequest>(_ request: Request, session: URLSession=session) async throws -> AsyncResponse {
        guard let urlRequest = URLRequest(request: request, baseURL: baseURL) else {
            throw RequestError.urlError(request: URLRequest(url: baseURL), error: URLError(.badURL))
        }
        
        do {
            let result = try await session.data(for: urlRequest)
            
            guard let httpResponse = result.1 as? HTTPURLResponse else {
                throw RequestError.urlError(request: urlRequest, error: URLError(.unknown))
            }
            
            if let httpError = RequestError(httpStatusCode: httpResponse.statusCode, request: urlRequest) {
                throw httpError
            } else {
                return (urlRequest, httpResponse, result.0)
            }
            
        } catch {
            switch error {
            case let requestError as RequestError:
                throw requestError
            case let urlError as URLError:
                throw RequestError.urlError(request: urlRequest, error: urlError)
            default:
                throw RequestError.other(request: urlRequest, message: error.localizedDescription)
            }
        }
        
    }
}
#endif
