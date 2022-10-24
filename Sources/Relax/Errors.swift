//
//  Errors.swift
//  
//
//  Created by Thomas De Leon on 5/13/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

//MARK: - Handling Errors
/// An error that occurs when making a `ServiceRequest`
///
/// This encapsulates errors while actually making a request (i.e. network connection issues), and does not include HTTP status code errors.
public enum RequestError: Error, Hashable {
    public static func == (lhs: RequestError, rhs: RequestError) -> Bool {
        switch (lhs, rhs) {
        case (.decoding(let lhsRequest, let lhsError), .decoding(let rhsRequest, let rhsError)):
            return lhsRequest.url == rhsRequest.url && lhsError.localizedDescription == rhsError.localizedDescription
        case (.decoding, _), (_, .decoding):
            return false
        default:
            return lhs == rhs
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(localizedDescription)
    }

    /// A   `URLError` occurred with the request
    case urlError(request: URLRequest, error: URLError)
    /// A `DecodingError` occurred when decoding data from the request
    case decoding(request: URLRequest, error: DecodingError)
    /// Other error occurred
    case other(request: URLRequest, message: String)
    
    public var localizedDescription: String {
        switch self {
        case .urlError(_, let error):
            return error.localizedDescription
        case .decoding(_, let error):
            return error.localizedDescription
        case .other(_, let message):
            return message
        }
    }
}

/// An HTTP error
public struct HTTPError: Error, Hashable {
    public static func == (lhs: HTTPError, rhs: HTTPError) -> Bool {
        lhs.statusCode == rhs.statusCode
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(statusCode)
    }
    
    public enum HTTPErrorType {
        /// 400 Bad request
        case badRequest
        /// 401 Unauthorized
        case unauthorized
        /// 404 Not found
        case notFound
        /// 429 Too many requests
        case tooManyRequests
        /// 5XX Server error
        case server
        /// Other status (not 1XX-3XX)
        case other
    }
    
    /// The status code returned
    public let statusCode: Int
    /// The http error type
    public let status: HTTPErrorType
    /// The response received
    public let response: Request.Response
    /// A localized description of the error
    public var localizedDescription: String {
        HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
    
    /// Create an HTTPError from a Response
    ///
    /// Creates an HTTPError for the given response based on the HTTP status code. Returns `nil` if no error (1XX-3XX status) occurred.
    /// - Parameter response: The response received
    public init?(response: Request.Response) {
        self.init(statusCode: response.response.statusCode, response: response)
    }
    
    init?(statusCode: Int, response: Request.Response) {
        switch statusCode {
        case 100...399:
            return nil
        case 400:
            self.status = .badRequest
        case 401:
            self.status = .unauthorized
        case 404:
            self.status = .notFound
        case 429:
            self.status = .tooManyRequests
        case 500...599:
            self.status = .server
        default:
            self.status = .other
        }
        
        self.statusCode = statusCode
        self.response = response
    }
}
