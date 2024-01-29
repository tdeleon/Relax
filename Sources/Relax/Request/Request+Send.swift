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
    ///   - session: When provided, overrides the ``Request/session`` defined in the Request.
    ///   - autoResumeTask: Whether to call `resume()` on the created task. The default is `true`.
    ///   - completion: A completion handler with the response from the server.
    /// - Returns: The task used to make the request
    /// - Warning: If `autoResumeTask` is `true`, do **not** call `resume()` on the returned task, as the it will already be called. Calling it yourself
    /// will result in the request being sent again.
    @discardableResult
    public func send(
        session: URLSession? = nil,
        autoResumeTask: Bool = true,
        completion: @escaping Request.Completion
    ) -> URLSessionDataTask {
        let task = (session ?? self.session).dataTask(with: urlRequest) { data, response, error in
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
    ///   - decoder: When set, overrides the ``Request/decoder`` used to decode received data.
    ///   - session: When set, overrides the ``Request/session`` used to send the request.
    ///   - completion: A completion handler with a `Result` of the model type decoded from received data, or ``RequestError`` on failure.
    ///
    ///
    /// Use this method when you want to decode data into a given model type, and do not need the full `HTTPURLResponse` from the server.
    ///
    /// ```swift
    /// let request = Request(.get, url: URL(string: "https://example.com")!)
    /// request.send { (result: Result<User, RequestError>) in
    ///     switch result {
    ///     case .success(let user):
    ///         print("User: \(user)")
    ///     case .failure(let error):
    ///         print("Request failed - \(error)")
    ///     }
    /// }
    /// ```
    ///
    public func send<ResponseModel: Decodable>(
        decoder: JSONDecoder? = nil,
        session: URLSession? = nil,
        completion: @escaping (_ result: Result<ResponseModel, RequestError>) -> Void
    ) {
        send(
            decoder: decoder,
            session: session
        ) { (result: Result<Request.ResponseModel<ResponseModel>, RequestError>) in
            switch result {
            case .success(let success):
                completion(.success(success.responseModel))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    /// Send a request with a completion handler, decoding the received data to a Decodable instance
    /// - Parameters:
    ///   - decoder: When set, overrides the ``Request/decoder`` used to decode received data.
    ///   - session: When set, overrides the ``Request/session`` used to send the request.
    ///   - completion: A completion handler with the response from the server, including the decoded data as the Decodable type.
    ///
    /// Use this method when decoding a model `Decodable` type and you also need the full `HTTPURLResponse` from the server.
    public func send<ResponseModel: Decodable>(
        decoder: JSONDecoder? = nil,
        session: URLSession? = nil,
        completion: @escaping Request.ModelCompletion<ResponseModel>
    ) {
        send(
            session: session,
            autoResumeTask: true
        ) { result in
            do {
                let success = try result.get()
                let decoded = try (decoder ?? self.decoder).decode(ResponseModel.self, from: success.data)
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

