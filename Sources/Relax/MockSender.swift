//
//  MockSender.swift
//  Relax
//
//  Created by Thomas De Leon on 5/8/26.
//

import Foundation
import HTTPTypes

public struct MockSender {
    public var response: @Sendable () -> (Data, HTTPResponse)
    public let delay: TimeInterval
    public var error: Error?
    
    public init(response: @Sendable @escaping () -> (Data, HTTPResponse), delay: TimeInterval = 0) {
        self.response = response
        self.delay = delay
    }
    
    public static func returning(
        _ object: Codable,
        status: HTTPResponse.Status = .ok,
        delay: TimeInterval = 0
    ) throws -> Self {
        let data = try JSONEncoder().encode(object)
        return try self.returning(data, status: status, delay: delay)
    }
    
    public static func returning(
        _ data: Data,
        status: HTTPResponse.Status = .ok,
        delay: TimeInterval = 0
    ) throws -> Self {
        self.init(response: { (data, HTTPResponse(status: status)) }, delay: delay)
    }
    
    public static func success(returning: Data, delay: TimeInterval = 0) throws -> Self {
        try self.returning(returning, status: .ok, delay: delay)
    }
    
    public static func success(returning: Codable, delay: TimeInterval = 0) throws -> Self {
        try self.returning(returning, status: .ok, delay: delay)
    }
}

extension MockSender: RequestSending {
    public func send(_ request: Request, options: SendOptions? = nil) async throws -> (Data, HTTPResponse) {
        try await mockResponse()
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
            let status = response().1
            return (URL.downloadsDirectory, status)
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
