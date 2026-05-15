//
//  Transport.swift
//  Relax
//
//  Created by Thomas De Leon on 5/13/26.
//

import Foundation
import HTTPTypes
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

internal protocol Transport: Sendable {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, HTTPResponse)
    func upload(
        for request: URLRequest,
        from body: Data,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, HTTPResponse)
    func upload(
        for request: URLRequest,
        with file: URL,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, HTTPResponse)
    func download(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (URL, HTTPResponse)
    func bytes(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (URLSession.AsyncBytes, HTTPResponse)
}
