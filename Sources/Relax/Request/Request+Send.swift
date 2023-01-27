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
    @discardableResult
    /// <#Description#>
    /// - Parameters:
    ///   - session: <#session description#>
    ///   - autoResumeTask: <#autoResumeTask description#>
    ///   - parseHTTPStatusErrors: <#parseHTTPStatusErrors description#>
    ///   - completion: <#completion description#>
    /// - Returns: <#description#>
    public func send(
        session: URLSession = .shared,
        autoResumeTask: Bool = true,
        parseHTTPStatusErrors: Bool = false,
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
            if parseHTTPStatusErrors,
               let httpError = HTTPError(response: requestResponse) {
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
    
    /// <#Description#>
    /// - Parameters:
    ///   - decoder: <#decoder description#>
    ///   - session: <#session description#>
    ///   - autoResumeTask: <#autoResumeTask description#>
    ///   - parseHTTPStatusErrors: <#parseHTTPStatusErrors description#>
    ///   - completion: <#completion description#>
    public func send<ResponseModel: Decodable>(
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession = .shared,
        autoResumeTask: Bool = true,
        parseHTTPStatusErrors: Bool = false,
        completion: @escaping Request.ModelCompletion<ResponseModel>
    ) {
        send(
            session: session,
            autoResumeTask: autoResumeTask,
            parseHTTPStatusErrors: parseHTTPStatusErrors
        ) { result in
            do {
                let success = try result.get()
                let decoded = try decoder.decode(ResponseModel.self, from: success.data)
                completion(.success((self, success.response, decoded)))
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

