//
//  Service+Async.swift
//  
//
//  Created by Thomas De Leon on 1/1/22.
//

#if swift(>=5.5)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Service {
    //MARK: - Making Requests
    /**
     Make a request asyncrhonously
     - Parameters:
        - request: The request to execute
        - session: The session to use. If not specified, the default provided by the `session` property of the `Service` will be used
     - Returns: A tuple containing the request, response, and data.
     - Throws: A `RequestError` of the error which occurred.
    */
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func request<Request: ServiceRequest>(_ request: Request, session: URLSession=session) async throws -> AsyncResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.request(request, session: session) { result in
                switch result {
                case .success(let successResponse):
                    guard let data = successResponse.data else {
                        continuation.resume(throwing: RequestError.other(request: URLRequest(url: baseURL), message: "No data was returned"))
                        return
                    }
                    continuation.resume(returning: (successResponse.request, successResponse.response, data))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
#endif
