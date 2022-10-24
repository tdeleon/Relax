//
//  Request+Publisher.swift
//  
//
//  Created by Thomas De Leon on 7/25/22.
//

#if canImport(Combine)
import Foundation
import Combine

extension Request {
    public typealias PublisherResponse = (request: URLRequest, response: HTTPURLResponse, data: Data)
    
    public typealias PublisherModelResponse<Model: Decodable> = (request: URLRequest, response: HTTPURLResponse, responseModel: Model)
    
    public func send(
        session: URLSession = .shared,
        timeout: TimeInterval? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) -> AnyPublisher<PublisherResponse, RequestError> {
        Future<PublisherResponse, RequestError> { promise in
            send(
                session: session,
                timeout: timeout,
                autoResumeTask: true) { result in
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
    
    public func send<ResponseModel: Decodable>(
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession = .shared,
        timeout: TimeInterval? = nil,
        cachePolicy: URLRequest.CachePolicy? = nil
    ) -> AnyPublisher<ResponseModel, RequestError> {
        send(session: session, timeout: timeout, cachePolicy: cachePolicy)
            .map(\.data)
            .decode(type: ResponseModel.self, decoder: decoder)
            .mapError { RequestError.decoding(request: urlRequest, error: $0 as! DecodingError) }
            .eraseToAnyPublisher()
    }
}

#endif
