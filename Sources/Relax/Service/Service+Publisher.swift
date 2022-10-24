//
//  Service+Publisher.swift
//  
//
//  Created by Thomas De Leon on 1/1/22.
//

#if canImport(Combine)
import Foundation
import Combine

extension Service {
    //MARK: - Making Requests
    
//    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
//    public func requestModelPublisher<Request: ServiceRequestDecodable>(
//        _ request: Request,
//        session: URLSession = session
//    ) -> AnyPublisher<PublisherModelResponse<Request.ResponseModel>, RequestError> {
//        requestPublisher(request, requestModel: Request.ResponseModel.self, decoder: request.decoder, session: session)
//    }
//
//    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
//    public func requestPublisher<Request: ServiceRequest, Model: Decodable>(
//        _ request: Request,
//        requestModel: Model.Type,
//        decoder: JSONDecoder = JSONDecoder(),
//        session: URLSession = session
//    ) -> AnyPublisher<PublisherModelResponse<Model>, RequestError> {
//        requestPublisher(for: request, session: session)
//            .tryMap { ($0.request, $0.response, try decoder.decode(Model.self, from: $0.data)) }
//            .mapError { RequestError.decoding(request: URLRequest(request: request, baseURL: baseURL)!, error: $0 as! DecodingError) }
//            .eraseToAnyPublisher()
//    }
//
//    // Renamed
//    /// :nodoc:
//    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
//    @available(*, deprecated, renamed: "requestPublisher(_:session:)")
//    public func request<Request: ServiceRequest>(
//        _ request: Request,
//        session: URLSession = session
//    ) -> AnyPublisher<PublisherResponse, RequestError> {
//        requestPublisher(for: request, session: session)
//    }
//
//    /**
//     Make a request using a Combine publisher.
//     - Parameters:
//        - request: The request to execute
//        - session: The session to use. If not specified, the default provided by the `session` property of the `Service` will be used
//        - Returns: A Combine publisher of type `PublisherResponse`.
//     */
//    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
//    public func requestPublisher<Request: ServiceRequest>(for request: Request, session: URLSession=session) -> AnyPublisher<PublisherResponse, RequestError> {
//        Future<PublisherResponse, RequestError> { promise in
//            self.request(request, session: session) { result in
//                switch result {
//                case .success(let successResponse):
//                    guard let data = successResponse.data else {
//                        promise(.failure(.other(request: URLRequest(request: request, baseURL: baseURL)!,
//                                                message: "No data was returned")))
//                        return
//                    }
//                    promise(.success((successResponse.request, successResponse.response, data)))
//                case .failure(let failure):
//                    promise(.failure(failure))
//                }
//            }
//        }
//        .eraseToAnyPublisher()
//    }
}
#endif
