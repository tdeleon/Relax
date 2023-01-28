//
//  MockError.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

extension RequestError.HTTPError {
    static func mock(_ statusCode: Int, request: Request) -> RequestError.HTTPError? {
        let urlResponse = HTTPURLResponse(
            url: URL(string: "https://example.com/")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return .init(statusCode: statusCode, response: (request, urlResponse, Data()))
    }
}
