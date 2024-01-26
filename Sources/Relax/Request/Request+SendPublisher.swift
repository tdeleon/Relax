//
//  Request+SendPublisher.swift
//  
//
//  Created by Thomas De Leon on 7/25/22.
//

#if canImport(Combine)
import Foundation
import Combine

extension Request {
    /// Response for an HTTP request using a Combine publisher
    ///
    /// - Parameters:
    ///    - request: The request made
    ///    - urlResponse: The response received
    ///    - data: Data received. If there is no data in the response, then this will be 0 bytes.
    public typealias PublisherResponse = (request: Request, urlResponse: HTTPURLResponse, data: Data)
    
    /// Response for an HTTP request using a Combine publisher, decoding a Decodable instance
    ///
    /// - Parameters:
    ///    - request: The request made
    ///    - urlResponse: The response received
    ///    - responseModel: The model decoded from received data
    public typealias PublisherModelResponse<Model: Decodable> = (request: Request, urlResponse: HTTPURLResponse, responseModel: Model)
    
    /// Send a request, returning a Combine publisher
    /// - Parameters:
    ///   - session: When provided, overrides the ``Request/session`` defined in the Request.
    /// - Returns: A Publisher which returns the received data, or a ``RequestError`` on failure.
    public func send(
        session: URLSession? = nil
    ) -> AnyPublisher<PublisherResponse, RequestError> {
        Future<PublisherResponse, RequestError> { promise in
            send(
                session: session,
                autoResumeTask: true
            ) { result in
                    switch result {
                    case .success(let successResponse):
                        promise(.success(successResponse))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    /// Send a request and decode received data to a Decodable instance, returning a Combine publisher
    /// - Parameters:
    ///   - decoder: The decoder to decode received data with. Default is `JSONDecoder()`.
    ///   - session: When provided, overrides the ``Request/session`` defined in the Request.
    /// - Returns: A Pubisher which returns the received data, or a ``RequestError`` on failure.
    public func send<ResponseModel: Decodable>(
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession? = nil
    ) -> AnyPublisher<ResponseModel, RequestError> {
        send(session: session)
            .map(\.data)
            .decode(type: ResponseModel.self, decoder: decoder)
            .mapError {
                switch $0 {
                case let error as DecodingError:
                    return RequestError.decoding(request: self, error: error)
                default:
                    return RequestError.other(request: self, message: $0.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}
#endif
