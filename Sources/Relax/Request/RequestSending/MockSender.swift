//
//  MockSender.swift
//  Relax
//
//  Created by Thomas De Leon on 5/8/26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPTypes

/// A convenience implementation of the ``RequestSending`` protocol to allow for mocking responses in tests.
public struct MockSender {
    /// The response to return
    public var response: @Sendable () -> (Data, HTTPResponse)
    /// A delay before invoking the response
    public let delay: TimeInterval
    /// An error to throw
    public var error: Error?
    
    /// Creates a new instance of MockSender specifying a response with data
    /// - Parameters:
    ///   - response: The response to return when a send function is called
    ///   - delay: Delay before response is returned
    public init(response: @Sendable @escaping () -> (Data, HTTPResponse), delay: TimeInterval = 0, error: Error? = nil) {
        self.response = response
        self.delay = delay
        self.error = error
    }
    
    /// Creates a MockSender with a codable response
    /// - Parameters:
    ///   - status: The HTTP status to return
    ///   - object: The codable object to return
    ///   - delay: Delay before returning the response
    ///   - headers: HTTP headers to return
    /// - Returns: A mock with the specified response parameters
    public static func returning(
        _ status: HTTPResponse.Status = .ok,
        object: Codable,
        headers: HTTPFields = [:],
        delay: TimeInterval = 0,
        error: Error? = nil
    ) throws -> Self {
        let data = try JSONEncoder().encode(object)
        return self.returning(status, data: data, headers: headers, delay: delay, error: error)
    }
    
    /// Creates a mock returning data
    /// - Parameters:
    ///   - status: The HTTP status to return
    ///   - data: The data to return
    ///   - delay: Delay before returning the response
    ///   - headers: HTTP headers to return
    /// - Returns: A mock with the specified response parameters.
    public static func returning(
        _ status: HTTPResponse.Status = .ok,
        data: Data = Data(),
        headers: HTTPFields = [:],
        delay: TimeInterval = 0,
        error: Error? = nil
    ) -> Self {
        self.init(response: { (data, HTTPResponse(status: status, headerFields: headers)) }, delay: delay, error: error)
    }
}

extension MockSender: RequestSending {
    public func send(_ request: Request, options: SendOptions? = nil) async throws -> (Data, HTTPResponse) {
        try await mockResponse()
    }
    
    public func send<Model>(
        _ request: Request,
        decoding: Model.Type,
        with decoder: JSONDecoder = JSONDecoder(),
        options: SendOptions? = nil
    ) async throws -> (Model, HTTPTypes.HTTPResponse) where Model : Decodable {
        let (data, response) = try await mockResponse()
        let model = try decoder.decode(Model.self, from: data)
        return (model, response)
    }
    
    public func send(
        _ request: Request,
        withFile file: URL,
        options: SendOptions? = nil
    ) async throws -> (Data, HTTPResponse) {
        try await mockResponse()
    }
    
    public func sendDownload(_ request: Request, options: SendOptions? = nil) async throws -> (URL, HTTPResponse) {
        try await Task.sleep(for: .seconds(delay))
        if let error {
            throw error
        } else {
            let (data, status) = response()
            let fileURL = URL.temporaryDirectory.appending(path: "RelaxMock-\(UUID().uuidString).data")
            try data.write(to: fileURL)
            return (fileURL, status)
        }
    }
    
    private func mockResponse() async throws -> (Data, HTTPResponse) {
        try await Task.sleep(for: .seconds(delay))
        if let error {
            throw error
        } else {
            return response()
        }
    }
}
