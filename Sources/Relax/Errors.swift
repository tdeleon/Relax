//
//  Errors.swift
//  
//
//  Created by Thomas De Leon on 5/13/20.
//

import Foundation
#if canImport(FoundationNetworking)
@preconcurrency import FoundationNetworking
#endif
import HTTPTypes

//MARK: - Handling Errors
/// An error that occurs when making a `ServiceRequest`
///
/// This encapsulates errors while making a request (i.e. network connection issues), and does not include HTTP status  errors.
public enum RequestError: Error, Hashable, Sendable {
    public static func ==(lhs: RequestError, rhs: RequestError) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(localizedDescription)
    }

    /// A   `URLError` occurred with the request
    case urlError(request: Request, error: URLError)
    /// A `DecodingError` occurred when decoding data from the request
    case decoding(request: Request, error: DecodingError)
    /// Other error occurred
    case other(request: Request, message: String)
    /// HTTP status code error
    case httpStatus(request: Request, error: HTTPError)
    
    public var localizedDescription: String {
        switch self {
        case .urlError(_, let error):
            return error.localizedDescription
        case .decoding(_, let error):
            return error.localizedDescription
        case .httpStatus(_, let error):
            return error.localizedDescription
        case .other(_, let message):
            return message
        }
    }
}

extension RequestError {
    /// An HTTP status code error
    ///
    /// Any HTTP status code which is considered an error- i.e. 3xx-5xx range
    public struct HTTPError: Error, Hashable, Sendable {
        
        public var status: HTTPResponse.Status {
            response.status
        }
        /// The http error type
        public var kind: HTTPResponse.Status.Kind {
            response.status.kind
        }
        /// The response received
        public let response: HTTPResponse
        /// A localized description of the error
        public var localizedDescription: String {
            status.description
        }
        
        /// Create an HTTPError from a Response
        ///
        /// Creates an HTTPError for the given response based on the HTTP status code. Returns `nil` if no error (1XX-3XX status) occurred.
        /// - Parameter response: The response received
        public init?(response: HTTPResponse) {
            self.response = response
        }
    }
}
