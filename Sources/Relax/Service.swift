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

 To define a service, implement the `Service` protocol. Each service has a distinct base URL, and all requests made
 to the service will use this base URL. Use services to logically group requests together for better organization and code
 reusability.

 > **Note:** For implementing dynamic base URLs (such as with different environments like Dev, Stage, Prod, etc),
 > it is not necessary to define multiple services.

 #### About the protocol
 This protocol only has two properties- `Service.baseURL` and `Service.session`. The `baseURL` property is required to be implemented, and provides
 the base URL used for all requests (see [Making Requests](Making%20Requests.html) for more on requests). The `session` property is a
 `URLSession` instance that requests are made using. This property has a default implementation of `URLSession.shared`, but you can override this
 with your own. Additionally, when making requests,  a session may be passed in per request.
 
 #### See Also
 `ServiceRequest`
 
*/
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
    
    /**
     Completion handler based response for an HTTP request
    
     - `request`: The request made
     - `response`: The response received
     - `data`: The data received, if any
     */
    typealias Response = (request: URLRequest, response: HTTPURLResponse, data: Data?)
    /**
     Response for an HTTP request using a Combine publisher
     
        - `request`: The request made
        - `response`: The response received
        - `data`: Data received
     */
    typealias PublisherResponse = (request: URLRequest, response: HTTPURLResponse, data: Data)
    
    typealias AsyncResponse = PublisherResponse
    
    /**
     Completion handler for requests made
     
     - Parameter result: Result receieved
     
     */
    typealias RequestCompletion = (_ result: Result<Response, RequestError>) -> ()
}

//MARK: - Making Requests
public extension Service {
    ///  Returns `URLSession.shared`.
    static var session: URLSession {
        return URLSession.shared
    }
    
    /**
     Make a request using the given `ServiceRequest` and parameters
     - Parameters:
        - request: The `ServiceRequest` to use
        - session: The session to use. If none is provided, the default `session` property on the service will be used.
        - autoResumeTask: If `true`, then `resume()` will be called automatically on the created `URLSessionDataTask`. Default value is `true`.
        - completion: A `RequestCompletion` handler which is executed when the task is completed.
     - Returns: A `URLSessionDataTask`, or `nil` if there was a failure in creating the task.
    
     Call this method to create a `URLSessionDataTask` for a given request. By default, the `resume()` will be called on the task, executing the request immediately.
     
     - Warning: When `autoResumeTask` is `true`, calling `resume()` on the returned task will cause the request to be executed again.
    */
    @discardableResult func request<Request: ServiceRequest>(_ request: Request, session: URLSession=session, autoResumeTask: Bool=true, completion: @escaping RequestCompletion) -> URLSessionDataTask? {
        // Create the URLRequest
        guard let urlRequest = URLRequest(request: request, baseURL: baseURL) else {
            completion(.failure(.urlError(request: URLRequest(url: baseURL), error: URLError(.badURL))))
            return nil
        }
        
        // Create the task
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                // Check for URLErrors
                if let urlError = error as? URLError {
                    return completion(.failure(.urlError(request: urlRequest, error: urlError)))
                }
                // Any other error
                return completion(.failure(.other(request: urlRequest, message: error!.localizedDescription)))
            }
            
            // Check for an HTTPURLResponse
            guard let response = response,
                let httpResponse = response as? HTTPURLResponse else {
                    return completion(.failure(.urlError(request: urlRequest, error: URLError(.unknown))))
            }
            // Check for http status code errors (4xx-5xx series)
            if let httpError = RequestError(httpStatusCode: httpResponse.statusCode, request: urlRequest) {
                completion(.failure(httpError))
            }
            // Success
            else {
                completion(.success((urlRequest, httpResponse, data)))
            }
        }
        if autoResumeTask {
            task.resume()
        }
        return task
    }
}

#if canImport(Combine)
extension Service {
    /**
     Make a request using a Combine publisher.
     - Parameters:
        - request: The request to execute
        - session: The session to use. If not specified, the default provided by the `session` property of the `Service` will be used
     - Returns: A Combine publisher of type `PublisherResponse`.
     */
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func request<Request: ServiceRequest>(_ request: Request, session: URLSession=session) -> AnyPublisher<PublisherResponse, RequestError> {
        guard let urlRequest = URLRequest(request: request, baseURL: baseURL) else {
            return Fail<PublisherResponse, RequestError>(error: .urlError(request: URLRequest(url: baseURL), error: URLError(.badURL)))
                .eraseToAnyPublisher()
        }
        // Create a data task publisher
        return session.dataTaskPublisher(for: urlRequest)
        // Convert the output to `RelaxPublisherResponse`, check for http errors
            .mapError { RequestError.urlError(request: urlRequest, error: $0) }
            .tryMap { output -> PublisherResponse in
                let response = output.response as! HTTPURLResponse
                
                if let httpError = RequestError(httpStatusCode: response.statusCode, request: urlRequest) {
                    throw httpError
                }
                
                return (urlRequest, response, output.data)
            }
            .mapError { $0 as? RequestError ?? RequestError.other(request: urlRequest, message: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
}
#endif

#if !canImport(FoundationNetworking) && swift(>=5.5) // Async has not been implemented in FoundationNetworking (Linux/Windows) yet
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
