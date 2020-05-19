//
//  Errors.swift
//  
//
//  Created by Thomas De Leon on 5/13/20.
//

import Foundation

//MARK: - Handling Errors
/// An error that occurs when making a `ServiceRequest`
public enum RequestError: Error {
    /// Bad request (HTTP status 400)
    case badRequest(request: URLRequest)
    /// Unauthorized (HTTP status 401)
    case unauthorized(request: URLRequest)
    /// Not found (HTTP status 404)
    case notFound(request: URLRequest)
    /// Server error occured (HTTP status 500-599
    case serverError(request: URLRequest)
    /// Another HTTP error status code occurred (besides 400, 401, 404, and outside the 200-399 success code range)
    case otherHTTP(request: URLRequest, status: Int)
    /// An invalid URL was provided for the request
    case invalidURL(baseURL: URL)
    /// A   `URLError` occurred with the request
    case urlError(request: URLRequest, error: URLError)
    /// No response was received
    case noResponse(request: URLRequest)
    /// Another error occurred
    case other(request: URLRequest, message: String)
    
    init?(httpStatusCode: Int, request: URLRequest) {
        switch httpStatusCode {
        case 100...399:
            return nil
        case 400:
            self = .badRequest(request: request)
        case 401:
            self = .unauthorized(request: request)
        case 404:
            self = .notFound(request: request)
        case 500...599:
            self = .serverError(request: request)
        default:
            self = .otherHTTP(request: request, status: httpStatusCode)
        }
    }
}
