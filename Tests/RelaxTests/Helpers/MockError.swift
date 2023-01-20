//
//  File.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import Foundation
@testable import Relax

extension HTTPError {
    static func mock(_ statusCode: Int, request: Request) -> HTTPError? {
        let urlResponse = HTTPURLResponse(
            url: URL(string: "https://example.com/")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return .init(statusCode: statusCode, response: (request, urlResponse, Data()))
    }
}
