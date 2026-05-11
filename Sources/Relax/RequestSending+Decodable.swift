//
//  RequestSending+Decodable.swift
//  Relax
//
//  Created by Thomas De Leon on 5/11/26.
//

import Foundation
import HTTPTypes

extension RequestSending {
    public func send<Model: Decodable>(
        _ request: Request,
        decoder: JSONDecoder = JSONDecoder(),
        options: SendOptions?
    ) async throws -> (Model, HTTPResponse) {
        let (data, response) = try await send(request, options: options)
        let decoded = try decoder.decode(Model.self, from: data)
        return (decoded, response)
    }
    
    public func send<Model: Decodable>(
        _ request: Request,
        withFile file: URL,
        decoder: JSONDecoder = JSONDecoder(),
        options: SendOptions? = nil
    ) async throws -> (Model, HTTPResponse) {
        let (data, response) = try await send(request, withFile: file, options: options)
        let decoded = try decoder.decode(Model.self, from: data)
        return (decoded, response)
    }
}
