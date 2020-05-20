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

/**
 A protocol to define a REST API service

 Implement this protocol to define a REST service. All endpoints defined to use this service will share
 the `Service.baseURL` and `Service.session` properties.
 
 For example, to define a service at `http://www.example.com`:
 
 ````
 struct ExampleService: Service {
    var baseURL: URL = URL(string: "https://www.example.com/")!
 }
 ````
 
 All endpoints will be appened to the `baseURL` value of "https://www.example.com/".
 
 #### See Also
 `ServiceRequest`
 
**/
public protocol Service {
    //MARK: - Properties
    /// The base URL of the service. This value is shared among all endpoints on the service.
    var baseURL: URL { get }
    
    /// The `URLSession` that requests to this service will use.
    ///
    /// The value of this property will be used for all requests made on this service, unless an override
    /// is provided to a given request.
    static var session: URLSession { get }
    
    //MARK: - Handling Responses
    
    /// Response for an HTTP request
    typealias Response<Request: ServiceRequest> = (request: Request, response: HTTPURLResponse, data: Data?)
    /// Response for an HTTP request using a Combine publisher
    typealias PublisherResponse<Request: ServiceRequest> = (request: Request, response: HTTPURLResponse, data: Data)
    /// Completion handler for requests made
    typealias RequestCompletion<Request: ServiceRequest> = (Result<Response<Request>, RequestError>) -> ()
}

//MARK: - Making Requests
public extension Service {
    ///  Returns `URLSession.shared`.
    static var session: URLSession {
        return URLSession.shared
    }
    
    /// Make a request using the given `ServiceRequest` and parameters
    /// - Parameters:
    ///   - request: The `ServiceRequest` to use
    ///   - session: The session to use. If none is provided, the default `session` property on the service will be used.
    ///   - autoResumeTask: If `true`, then `resume()` will be called automatically on the created `URLSessionDataTask`. Default value is `true`.
    ///   - completion: A `RequestCompletion` handler which is executed when the task is completed.
    /// - Returns: A `URLSessionDataTask`, or `nil` if there was a failure in creating the task.
    ///
    /// Call this method to create a `URLSessionDataTask` for a given request. By default, the `resume()` will be called on the task, executing the request immediately.
    ///
    /// - Warning: When `autoResumeTask` is `true`, calling `resume()` on the returned task will cause the request to be executed again.
    ///
    @discardableResult func request<Request: ServiceRequest>(_ request: Request, session: URLSession=session, autoResumeTask: Bool=true, completion: @escaping RequestCompletion<Request>) -> URLSessionDataTask? {
        // Create the URLRequest
        guard let urlRequest = URLRequest(request: request, baseURL: baseURL) else {
            completion(.failure(.invalidURL(baseURL: baseURL)))
            return nil
        }
        
        // Create the task
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                // Check for URLErrors
                if let urlError = error as? URLError {
                    return completion(.failure(.urlError(request: urlRequest, error: urlError)))
                }
                // Check for any other error
                else {
                    return completion(.failure(.other(request: urlRequest, message: error!.localizedDescription)))
                }
            }
            
            // Check for an HTTPURLResponse
            guard let response = response,
                let httpResponse = response as? HTTPURLResponse else {
                    return completion(.failure(.noResponse(request: urlRequest)))
            }
            // Check for http status code errors (4xx-5xx series)
            if let httpError = RequestError(httpStatusCode: httpResponse.statusCode, request: urlRequest) {
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
public extension Service {
    /// Make a request using a Combine publisher.
    /// - Parameters:
    ///   - request: The request to execute
    ///   - session: The session to use. If not specified, the default provided by the `session` property of the `Service` will be used
    /// - Returns: A Combine publisher of type `PublisherResponse`.
    func request<Request: ServiceRequest>(_ request: Request, session: URLSession=session) -> AnyPublisher<PublisherResponse<Request>, RequestError> {
        guard let urlRequest = URLRequest(request: request, baseURL: baseURL) else {
            return Fail(outputType: PublisherResponse.self, failure: .invalidURL(baseURL: baseURL))
                .eraseToAnyPublisher()
        }
        // Create a data task publisher
        return session.dataTaskPublisher(for: urlRequest)
            // Convert the output to `RelaxPublisherResponse`, check for http errors
            .tryMap { output -> PublisherResponse<Request> in
                guard let response = output.response as? HTTPURLResponse else {
                    throw RequestError.noResponse(request: urlRequest)
                }
                
                if let httpError = RequestError(httpStatusCode: response.statusCode, request: urlRequest) {
                    throw httpError
                }
                
                return (request, response, output.data)
        }
            // Convert errors to `RelaxRequestError`
        .mapError { error in
            if let relaxError = error as? RequestError {
                return relaxError
            }
            if let urlError = error as? URLError {
                return .urlError(request: urlRequest, error: urlError)
            }
            return .other(request: urlRequest, message: error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }
}
