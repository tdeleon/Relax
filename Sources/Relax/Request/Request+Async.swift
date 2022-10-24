//
//  Request+Async.swift
//  
//
//  Created by Thomas De Leon on 7/25/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Request {
    public typealias AsyncResponse = (request: URLRequest, response: HTTPURLResponse, data: Data)
    
    public typealias AsyncModelResponse<Model: Decodable> = (responseModel: Model, response: HTTPURLResponse)
    
    public func send(session: URLSession = .shared, timeout: TimeInterval? = nil) async throws -> AsyncResponse {
        var task: URLSessionDataTask?
        let onCancel = { task?.cancel() }
        
        return try await withTaskCancellationHandler {
            onCancel()
        } operation: {
            try Task.checkCancellation()
            
            return try await withCheckedThrowingContinuation { continuation in
                task = send(
                    session: session,
                    timeout: timeout,
                    autoResumeTask: true) { result in
                        switch result {
                        case .success(let successResponse):
                            continuation.resume(returning: successResponse)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
            }
        }
    }
    
    public func send<ResponseModel: Decodable>(
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession = .shared,
        timeout: TimeInterval? = nil
    ) async throws -> ResponseModel {
        let response: AsyncResponse = try await send(session: session, timeout: timeout)
        return try decoder.decode(ResponseModel.self, from: response.data)
    }
}
