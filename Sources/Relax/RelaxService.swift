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

public protocol RelaxService {
    var baseURL: URL { get }
    
    typealias RelaxResponse<Request: RelaxRequest> = (request: Request, response: HTTPURLResponse, data: Data?)
    typealias RelaxPublisherResponse<Request: RelaxRequest> = (request: Request, response: HTTPURLResponse, data: Data?)
    typealias RelaxResult<Request: RelaxRequest> = Result<RelaxResponse<Request>, RelaxRequestError>
    typealias RelaxRequestCompletion<Request: RelaxRequest> = (RelaxResult<Request>) -> ()
}

public enum RelaxRequestError: Error {
    case badRequest(request: RelaxRequest)
    case unauthorized(request: RelaxRequest)
    case notFound(request: RelaxRequest)
    case otherHTTP(request: RelaxRequest, status: Int)
    case invalidURL(request: RelaxRequest)
    case urlError(request: RelaxRequest, error: URLError)
    case noResponse(request: RelaxRequest)
    case other(request: RelaxRequest, message: String)
    
    init?(httpStatusCode: Int, request: RelaxRequest) {
        switch httpStatusCode {
        case 200...399:
            return nil
        case 400:
            self = .badRequest(request: request)
        case 401:
            self = .unauthorized(request: request)
        case 404:
            self = .notFound(request: request)
        default:
            self = .otherHTTP(request: request, status: httpStatusCode)
        }
    }
}

public extension RelaxService {
    static var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            configuration.waitsForConnectivity = true
        }
        
        return URLSession(configuration: configuration)
    }
    
    @discardableResult func make<Request: RelaxRequest>(_ request: Request, session: URLSession=session, autoResumeTask: Bool=true, completion: @escaping RelaxRequestCompletion<Request>) -> URLSessionDataTask? {
        guard let urlRequest = URLRequest(request: request) else {
            completion(.failure(.invalidURL(request: request)))
            return nil
        }
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                if let urlError = error as? URLError {
                    return completion(.failure(.urlError(request: request, error: urlError)))
                }
                else {
                    return completion(.failure(.other(request: request, message: error!.localizedDescription)))
                }
            }
            
            guard let response = response,
                let httpResponse = response as? HTTPURLResponse else {
                    return completion(.failure(.noResponse(request: request)))
            }
            
            if let httpError = RelaxRequestError(httpStatusCode: httpResponse.statusCode, request: request) {
                completion(.failure(httpError))
            }
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
    func make<Request: RelaxRequest>(_ request: Request, session: URLSession=session) -> AnyPublisher<RelaxPublisherResponse<Request>, RelaxRequestError> {
        guard let urlRequest = URLRequest(request: request) else {
            return Fail(outputType: RelaxPublisherResponse<Request>.self, failure: .badRequest(request: request))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { output -> RelaxPublisherResponse<Request> in
                guard let response = output.response as? HTTPURLResponse else {
                    throw RelaxRequestError.noResponse(request: request)
                }
                
                if let httpError = RelaxRequestError(httpStatusCode: response.statusCode, request: request) {
                    throw httpError
                }
                
                return (request, response, output.data)
        }
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
