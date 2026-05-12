//
//  RequestErrorTests.swift
//  
//
//  Created by Thomas De Leon on 1/24/23.
//

import Foundation
import Testing
import HTTPTypes
#if canImport(FoundationNetworking)
@preconcurrency import FoundationNetworking
#endif
@testable import Relax

struct RequestErrorTests {
    private enum Key: String, CodingKey {
        case root
    }
    
    private let request = Request(.get, url: URL(string: "https://example.com/")!)
    
    @Test(arguments: [0, 53, 99, 100, 200, 204, 399, 400, 401, 404, 429, 499, 500, 599, 600, 999])
    func `HTTPError only created for 4XX-5XX status codes`(code: Int) async throws {
        let response = HTTPResponse(status: HTTPResponse.Status(code: code))
        let error = RequestError.HTTPError(response: response)
        
        switch code {
        case 100...399:
            #expect(error == nil)
        case 400...499:
            #expect(error?.kind == .client)
        case 500...599:
            #expect(error?.kind == .server)
        default:
            #expect(error?.kind == .invalid)
        }
        
    }
    
    @Test func `Correct localized description for error type`() async throws {
        let urlError = URLError(.networkConnectionLost)
        let requestErrorURL = RequestError.urlError(request: request, error: urlError)
        #expect(requestErrorURL.localizedDescription == urlError.localizedDescription)
        

        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [Key.root], debugDescription: "Debug"))
        let requestErrorDecoding = RequestError.decoding(request: request, error: decodingError)
        #expect(requestErrorDecoding.localizedDescription == decodingError.localizedDescription)

        let response = HTTPResponse(status: .badRequest)
        let httpStatusError = try #require(RequestError.HTTPError(response: response))
        let requestErrorHTTP = RequestError.httpStatus(request: request, error: httpStatusError)
        #expect(requestErrorHTTP.localizedDescription == httpStatusError.localizedDescription)
        
        let message = "Error message"
        let requestErrorOther = RequestError.other(request: request, message: message)
        #expect(requestErrorOther.localizedDescription == message)
    }
    
    @Test func `Correct debug description`() async throws {
        // URLError
        let urlError = URLError(.badServerResponse)
        let requestErrorURL = RequestError.urlError(request: request, error: urlError)
        #expect(requestErrorURL.debugDescription == """
            RequestError.URLError: \(urlError.errorCode)

            \(request)
            """
        )
        
        // Decoding error
        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [Key.root], debugDescription: "Description"))
        let requestErrorDecoding = RequestError.decoding(
            request: request,
            error: decodingError
        )
        #expect(requestErrorDecoding.debugDescription == """
            RequestError.Decoding: \(decodingError)

            \(request)
            """
        )
        
        // HTTPStatus
        let httpStatusError = try #require(RequestError.HTTPError(response: HTTPResponse(status: .badGateway)))
        let requestErrorHTTPStatus = RequestError.httpStatus(
            request: request,
            error: httpStatusError
        )
        #expect(requestErrorHTTPStatus.debugDescription == """
            RequestError.HTTPStatus: \(httpStatusError.localizedDescription)

            \(request)
            """)
        
        // Other error
        let message = "Some error message"
        let requestErrorOther = RequestError.other(request: request, message: message)
        #expect(requestErrorOther.debugDescription == """
            RequestError.Other: \(message)

            \(request)
            """)
    }
    
    @Test func `Hashable conformance`() async throws {
        // URLError
        let requestErrorURL = RequestError.urlError(request: request, error: URLError(.badURL))
        let requestErrorURL1 = RequestError.urlError(request: request, error: URLError(.networkConnectionLost))
        var copy = requestErrorURL
        #expect(requestErrorURL.hashValue == copy.hashValue)
        #expect(requestErrorURL == copy)
        #expect(requestErrorURL1 != requestErrorURL)
        
        // Decoding error
        let requestErrorDecoding = RequestError.decoding(
            request: request,
            error: .dataCorrupted(.init(codingPath: [Key.root], debugDescription: "Description"))
        )
        let requestErrorDecoding1 = RequestError.decoding(
            request: request,
            error: .keyNotFound(Key.root, .init(codingPath: [Key.root], debugDescription: "Description"))
        )
        copy = requestErrorDecoding
        #expect(requestErrorDecoding.hashValue == copy.hashValue)
        #expect(requestErrorDecoding == copy)
        #expect(requestErrorDecoding != requestErrorDecoding1)
        
        // HTTPStatus
        let requestErrorHTTPStatus = RequestError.httpStatus(
            request: request,
            error: try #require(.init(response: HTTPResponse(status: .badGateway)))
        )
        let requestErrorHTTPStatus1 = RequestError.httpStatus(
            request: request,
            error: try #require(.init(response: HTTPResponse(status: .badRequest)))
        )
        copy = requestErrorHTTPStatus
        #expect(requestErrorHTTPStatus.hashValue == copy.hashValue)
        #expect(requestErrorHTTPStatus == copy)
        #expect(requestErrorHTTPStatus != requestErrorHTTPStatus1)
        
        // Other error
        let requestErrorOther = RequestError.other(request: request, message: "Message")
        let requestErrorOther1 = RequestError.other(request: request, message: "Message1")
        copy = requestErrorOther
        #expect(requestErrorOther.hashValue == copy.hashValue)
        #expect(requestErrorOther == copy)
        #expect(requestErrorOther != requestErrorOther1)
    }
}
