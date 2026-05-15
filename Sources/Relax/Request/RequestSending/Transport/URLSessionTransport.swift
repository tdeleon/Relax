//
//  URLSessionTransport.swift
//  Relax
//
//  Created by Thomas De Leon on 5/12/26.
//

import Foundation
import HTTPTypes
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal struct URLSessionTransport: Transport {
    internal let session: URLSession

    internal func data(
        for request: URLRequest,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, HTTPResponse) {
        try await session.data(for: request, delegate: delegate)
    }
    
    internal func upload(
        for request: URLRequest,
        from body: Data,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, HTTPResponse) {
        try await session.upload(for: request, from: body, delegate: delegate)
    }
    
    internal func upload(
        for request: URLRequest,
        with file: URL,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, HTTPResponse) {
        try await session.upload(for: request, fromFile: file, delegate: delegate)
    }
    
    internal func download(
        for request: URLRequest,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (URL, HTTPResponse) {
        try await session.download(for: request, delegate: delegate)
    }
    
    internal func bytes(
        for request: URLRequest,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (URLSession.AsyncBytes, HTTPResponse) {
        try await session.bytes(for: request, delegate: delegate)
    }
}
