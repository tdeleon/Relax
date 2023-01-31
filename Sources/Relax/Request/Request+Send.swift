//
//  Request+Send.swift
//  
//
//  Created by Thomas De Leon on 1/24/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Request {
    /// Response for receiving data from an HTTP request
    ///
    /// - Parameters:
    ///    - request: The request made
    ///    - urlResponse: The response received
    ///    - data: Data received in the request. If there is no data in the response, then this will be 0 bytes.
    public typealias Response = (request: Request, urlResponse: HTTPURLResponse, data: Data)
    
    /// Response for decoding Decodable objects from an HTTP request
    ///
    /// - Parameters:
    ///    - request: The request made
    ///    - urlResponse: The response received
    ///    - responseModel: The model decoded from data received
    public typealias ResponseModel<Model: Decodable> = (request: Request, urlResponse: HTTPURLResponse, responseModel: Model)

    /// Completion handler response for a request
    public typealias Completion = (_ result: Result<Response, RequestError>) -> Void
    
    /// Completion handler response for decoding a Decodable object from a request
    public typealias ModelCompletion<Model: Decodable> = (_ result: Result<ResponseModel<Model>, RequestError>) -> Void
    
    /// Send a request with a completion handler, returning a data task
    /// - Parameters:
    ///   - session: The session to use to send the request. Default is `URLSession.shared`.
    ///   - autoResumeTask: Whether to call `resume()` on the created task. The default is `true`.
    ///   - parseHTTPStatusErrors: Whether to parse HTTP status codes returned for errors. The default is `false`.
    ///   - completion: A completion handler with the response from the server.
    /// - Returns: The task used to make the request
    /// - Warning: If `autoResumeTask` is `true`, do **not** call `resume()` on the returned task, as the it will already be called. Calling it yourself
    /// will result in the request being sent again.
    @discardableResult
    public func send(
        session: URLSession = .shared,
        autoResumeTask: Bool = true,
        completion: @escaping Request.Completion
    ) -> URLSessionDataTask {
        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard error == nil,
                  let data = data else {
                // Check for URLErrors
                if let urlError = error as? URLError {
                    return completion(.failure(.urlError(request: self, error: urlError)))
                }
                // Any other error
                return completion(.failure(.other(request: self, message: error!.localizedDescription)))
            }
            
            // Check for an HTTPURLResponse
            guard let response = response,
                  let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.urlError(request: self, error: URLError(.unknown))))
            }
            
            let requestResponse = (self, httpResponse, data)
            
            // Check for http status code errors (4xx-5xx series)
            if configuration.parseHTTPStatusErrors,
               let httpError = RequestError.HTTPError(response: requestResponse) {
                completion(.failure(RequestError.httpStatus(request: self, error: httpError)))
            }
            // Success
            else {
                completion(.success(requestResponse))
            }
        }
        
        if autoResumeTask {
            task.resume()
        }
        
        return task
    }
    
    /// Send a request with a completion handler, decoding the received data to a Decodable instance
    /// - Parameters:
    ///   - decoder: The decoder to decode received data with. Default is `JSONDecoder()`.
    ///   - session: The session to use to send the request. Default is `URLSession.shared`.
    ///   - parseHTTPStatusErrors: Whether to parse HTTP status codes returned for errors. The default is `false`.
    ///   - completion: A completion handler with the response from the server, including the decoded data as the Decodable type.
    public func send<ResponseModel: Decodable>(
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession = .shared,
        completion: @escaping Request.ModelCompletion<ResponseModel>
    ) {
        send(
            session: session,
            autoResumeTask: true
        ) { result in
            do {
                let success = try result.get()
                let decoded = try decoder.decode(ResponseModel.self, from: success.data)
                completion(.success((self, success.urlResponse, decoded)))
            } catch let error as DecodingError {
                completion(.failure(.decoding(request: self, error: error)))
            } catch let error as RequestError {
                completion(.failure(error))
            } catch {
                completion(.failure(.other(request: self, message: error.localizedDescription)))
            }
        }
    }
}

