//
//  URLSession+HTTPTypesTests.swift
//  Relax
//
//  Created by Thomas De Leon on 5/13/26.
//

import Foundation
import Testing
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HTTPTypes

@testable import Relax

struct URLSessionHTTPTypesTests {

    @Test func `Convert HTTPURLResponse to HTTPResponse`() async throws {
        let fields = HTTPFields {
            HTTPField(name: .accept, value: "application/json")
        }
        let httpResponse = HTTPResponse(status: .accepted, headerFields: fields)
        let httpURLResponse = try #require(
            HTTPURLResponse(httpResponse: httpResponse, url: URL(string: "https://example.com/")!)
        )
        
        #expect(try httpURLResponse.httpResponse == httpResponse)
    }

    @Test func `Failed URLResponse to HTTPResponse conversion throws URLError.badServerResponse`() async throws {
        let urlResponse = URLResponse(
            url: URL(string: "https://example.com")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        
        #expect(throws: URLError(.badServerResponse)) {
            try urlResponse.httpResponse
        }
    }
}
