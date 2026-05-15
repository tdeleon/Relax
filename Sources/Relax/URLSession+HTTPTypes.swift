//
//  URLSession+HTTPTypes.swift
//  Relax
//
//  Created by Thomas De Leon on 5/13/26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPTypes

extension URLSession {
    internal func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, HTTPResponse) {
        let response: (data: Data, urlResponse: URLResponse) = try await data(for: request, delegate: delegate)
        return (response.data, try response.urlResponse.httpResponse)
    }
    
    internal func upload(
        for request: URLRequest,
        from body: Data,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, HTTPResponse) {
        let response: (data: Data, urlResponse: URLResponse) = try await upload(
            for: request,
            from: body,
            delegate: delegate
        )
        return (response.data, try response.urlResponse.httpResponse)
    }
    
    internal func upload(
        for request: URLRequest,
        fromFile file: URL,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, HTTPResponse) {
        let response: (data: Data, urlResponse: URLResponse) = try await upload(
            for: request,
            fromFile: file,
            delegate: delegate
        )
        return (response.data, try response.urlResponse.httpResponse)
    }
    
    internal func download(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (URL, HTTPResponse) {
        let response: (url: URL, urlResponse: URLResponse) = try await download(for: request, delegate: delegate)
        return (response.url, try response.urlResponse.httpResponse)
    }
    
    internal func download(
        resumeFrom data: Data,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (URL, HTTPResponse) {
        let response: (url: URL, urlResponse: URLResponse) = try await download(resumeFrom: data, delegate: delegate)
        return (response.url, try response.urlResponse.httpResponse)
    }
    
    #if !canImport(FoundationNetworking)
    internal func bytes(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (URLSession.AsyncBytes, HTTPResponse) {
        let response: (bytes: URLSession.AsyncBytes, urlResponse: URLResponse) = try await bytes(
            for: request,
            delegate: delegate
        )
        return (response.bytes, try response.urlResponse.httpResponse)
    }
    #endif
}

extension URLResponse {
    internal var httpResponse: HTTPResponse {
        get throws {
            guard let response = (self as? HTTPURLResponse)?.httpResponse else { throw URLError(.badServerResponse) }
            return response
        }
    }
}
