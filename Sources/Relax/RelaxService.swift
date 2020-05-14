//
//  RelaxService.swift
//
//
//  Created by Thomas De Leon on 5/12/20.
//

import Foundation
#if canImport(Combine)
import Combine
#endif

/**
 A protocol to define a REST API service

 Implement this protocol to define a REST service. All endpoints defined to use this service will share
 the `RelaxService.baseURL` and `RelaxService.session` properties.
 
 For example, to define a service at `http://www.example.com`:
 
 ````
 struct ExampleService: RelaxService {
    var baseURL: URL = URL(string: "https://www.example.com/")!
 }
 ````
 
 All endpoints will be appened to the `baseURL` value of "https://www.example.com/".
 
 See also: `RelaxEndpoint`, `RelaxRequest`
 
**/
public protocol RelaxService {
    /// The base URL of the service. This value is shared among all endpoints on the service.
    var baseURL: URL { get }
    
    /// Response for an HTTP request
    typealias RelaxResponse<Request: RelaxRequest> = (request: Request, response: HTTPURLResponse, data: Data?)
    /// Response for an HTTP request using a Combine publisher
    typealias RelaxPublisherResponse<Request: RelaxRequest> = (request: Request, response: HTTPURLResponse, data: Data)
    /// Completion handler for requests made
    typealias RelaxRequestCompletion<Request: RelaxRequest> = (Result<RelaxResponse<Request>, RelaxRequestError>) -> ()
}
//MARK: - Making Requests
public extension RelaxService {
    /// A default `URLSession` instance which requests will use if another is not provided.
    ///
    /// The configuration of this session has `timeoutIntervalForRequest` and `timeoutIntervalForResource` values of 30,
    /// and `waitsForConnectivity` set to true (for supported platform versions).
    static var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            configuration.waitsForConnectivity = true
        }
        
        return URLSession(configuration: configuration)
    }
    
    /// Make a request using the given `RelaxRequest` and parameters
    /// - Parameters:
    ///   - request: The `RelaxRequest` to use
    ///   - session: The session to use. If none is provided, the default `session` property on the service will be used.
    ///   - autoResumeTask: If `true`, then `resume()` will be called automatically on the created `URLSessionDataTask`. Default value is `true`.
    ///   - completion: A `RelaxRequestCompletion` handler which is executed when the task is completed.
    /// - Returns: A `URLSessionDataTask`, or `nil` if there was a failure in creating the task.
    ///
    /// Call this method to create a `URLSessionDataTask` for a given request. By default, the `resume()` will be called on the task, executing the request immediately.
    ///
    /// - Warning: When `autoResumeTask` is `true`, calling `resume()` on the returned task will cause the request to be executed again.
    ///
    @discardableResult func make<Request: RelaxRequest>(_ request: Request, session: URLSession=session, autoResumeTask: Bool=true, completion: @escaping RelaxRequestCompletion<Request>) -> URLSessionDataTask? {
        // Create the URLRequest
        guard let urlRequest = URLRequest(request: request) else {
            completion(.failure(.invalidURL(request: request)))
            return nil
        }
        
        // Create the task
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                // Check for URLErrors
                if let urlError = error as? URLError {
                    return completion(.failure(.urlError(request: request, error: urlError)))
                }
                // Check for any other error
                else {
                    return completion(.failure(.other(request: request, message: error!.localizedDescription)))
                }
            }
            
            // Check for an HTTPURLResponse
            guard let response = response,
                let httpResponse = response as? HTTPURLResponse else {
                    return completion(.failure(.noResponse(request: request)))
            }
            // Check for http status code errors (4xx-5xx series)
            if let httpError = RelaxRequestError(httpStatusCode: httpResponse.statusCode, request: request) {
                completion(.failure(httpError))
            }
            // Success
            else {
                completion(.success((request, httpResponse, data)))
            }
        }
        if autoResumeTask {
            task.resume()
        }
        return task
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension RelaxService {
    /// Make a request using a Combine publisher.
    /// - Parameters:
    ///   - request: The request to execute
    ///   - session: The session to use. If not specified, the default provided by the `session` property of the `RelaxService` will be used
    /// - Returns: A Combine publisher of type `RelaxPublisherResponse`.
    func make<Request: RelaxRequest>(_ request: Request, session: URLSession=session) -> AnyPublisher<RelaxPublisherResponse<Request>, RelaxRequestError> {
        guard let urlRequest = URLRequest(request: request) else {
            return Fail(outputType: RelaxPublisherResponse<Request>.self, failure: .badRequest(request: request))
                .eraseToAnyPublisher()
        }
        // Create a data task publisher
        return session.dataTaskPublisher(for: urlRequest)
            // Convert the output to `RelaxPublisherResponse`, check for http errors
            .tryMap { output -> RelaxPublisherResponse<Request> in
                guard let response = output.response as? HTTPURLResponse else {
                    throw RelaxRequestError.noResponse(request: request)
                }
                
                if let httpError = RelaxRequestError(httpStatusCode: response.statusCode, request: request) {
                    throw httpError
                }
                
                return (request, response, output.data)
        }
            // Convert errors to `RelaxRequestError`
        .mapError { error in
            if let relaxError = error as? RelaxRequestError {
                return relaxError
            }
            if let urlError = error as? URLError {
                return .urlError(request: request, error: urlError)
            }
            return .other(request: request, message: error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }
}
