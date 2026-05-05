//
//  RequestSending.swift
//  Relax
//
//  Created by Thomas De Leon on 4/29/26.
//

import Foundation

/// A protocol for sending network requests and receiving raw responses
///
/// Use the default implementation, ``URLSessionSender`` to send requests using `URLSession`. For testing, you can use an implementation which
/// returns mock data from the ``URLSessionSender/send``
public protocol RequestSending: Sendable {
    
    /// Sends a request
    /// - Parameter request: The request to send
    /// - Returns: The HTTPURLResponse and raw data response from the request
    func send(_ request: Request) async throws -> (HTTPURLResponse, Data)
}

/// The default implementation for sending Requests
///
/// This implementation of the `RequestSending` protocol uses an instance of `URLSession` to send network requests.
public struct URLSessionSender: RequestSending {
    public let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func send(_ request: Request) async throws -> (HTTPURLResponse, Data) {
        let (data, response) = try await session.data(for: request.urlRequest)
        guard let urlResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        return (urlResponse, data)
    }
}

public struct MockSender: RequestSending {
    public var response: @Sendable () -> (HTTPURLResponse, Data)
    public let delay: TimeInterval
    
    public init(response: @Sendable @escaping () -> (HTTPURLResponse, Data), delay: TimeInterval = 0) {
        self.response = response
        self.delay = delay
    }
    
    public static func returning(_ object: Codable, statusCode: Int = 200, delay: TimeInterval = 0) throws -> Self? {
        guard let data = try? JSONEncoder().encode(object),
              let httpURLResponse = HTTPURLResponse(url: URL(string: "https://example.com/")!, statusCode: statusCode, httpVersion: nil, headerFields: [:])
        else { return nil }
        
        return self.init(response: { (httpURLResponse, data) }, delay: delay)
    }
    
    public func send(_ request: Request) async throws -> (HTTPURLResponse, Data) {
        try await Task.sleep(for: .seconds(delay))
        return response()
    }
}
