//
//  Response.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation
import HTTPTypes

public struct Response: Sendable {
    let summary: String?
    let description: String?
    let httpStatus: HTTPResponse.Status?
    let kind: HTTPResponse.Status.Kind?
    let accept: HTTPField.MediaType?
    let content: Payload
    
    public enum Payload: @unchecked Sendable {
        case empty
        case data
        case json(_ type: Decodable.Type)
        case jsonDictionary
        case text(_ encoding: String.Encoding = .utf8)
    }
    
    internal init(
        status: HTTPResponse.Status?,
        kind: HTTPResponse.Status.Kind?,
        accept: HTTPField.MediaType?,
        summary: String?,
        description: String?,
        content: Payload
    ) {
        self.summary = summary
        self.description = description
        self.httpStatus = status
        self.kind = kind ?? status?.kind
        self.accept = accept
        self.content = content
    }
    
    //MARK: - JSON
    
    /// A JSON response for an HTTP status
    /// - Parameters:
    ///   - status: The status the response is expected for
    ///   - schema: The expected JSON object
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func json(
        _ status: HTTPResponse.Status,
        returning schema: Decodable.Type,
        accept: HTTPField.MediaType? = .applicationJSON,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: status,
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .json(schema)
        )
    }
    
    /// A JSON response for an HTTP status code
    /// - Parameters:
    ///   - code: The code the response is expected for
    ///   - schema: The expected JSON object
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func json(
        code: Int,
        returning schema: Decodable.Type,
        accept: HTTPField.MediaType? = .applicationJSON,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: HTTPResponse.Status(code: code),
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .json(schema)
        )
    }
    
    /// A JSON response for a kind of HTTP status
    /// - Parameters:
    ///   - kind: The kind of status the response is expected for
    ///   - schema: The expected JSON object
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func json(
        kind: HTTPResponse.Status.Kind,
        returning schema: Decodable.Type,
        accept: HTTPField.MediaType? = .applicationJSON,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: nil,
            kind: kind,
            accept: accept,
            summary: summary,
            description: description(),
            content: .json(schema)
        )
    }
    
    /// A JSON dictionary response for an HTTP status
    /// - Parameters:
    ///   - status: The status the response is expected for
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func jsonDictionary(
        _ status: HTTPResponse.Status,
        accept: HTTPField.MediaType? = .applicationJSON,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: status,
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .jsonDictionary
        )
    }
    
    /// A JSON dictionary response for an HTTP status code
    /// - Parameters:
    ///   - code: The code the response is expected for
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func jsonDictionary(
        code: Int,
        accept: HTTPField.MediaType? = .applicationJSON,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: HTTPResponse.Status(code: code),
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .jsonDictionary
        )
    }
    
    /// A JSON dictionary response for a kind of HTTP status
    /// - Parameters:
    ///   - kind: The kind of status the response is expected for
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func jsonDictionary(
        kind: HTTPResponse.Status.Kind,
        accept: HTTPField.MediaType? = .applicationJSON,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: nil,
            kind: kind,
            accept: accept,
            summary: summary,
            description: description(),
            content: .jsonDictionary
        )
    }
    
    //MARK: Text
    
    /// A text response for an HTTP status
    /// - Parameters:
    ///   - status: The status the response is expected for
    ///   - encoding: The string encoding to expect
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func text(
        _ status: HTTPResponse.Status,
        encoding: String.Encoding = .utf8,
        accept: HTTPField.MediaType? = .textPlain,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: status,
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .text(encoding)
        )
    }
    
    /// A text response for an HTTP status code
    /// - Parameters:
    ///   - code: The code the response is expected for
    ///   - encoding: The string encoding to expect
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func text(
        code: Int,
        encoding: String.Encoding = .utf8,
        accept: HTTPField.MediaType? = .textPlain,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: HTTPResponse.Status(code: code),
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .text(encoding)
        )
    }
    
    /// A text response for a kind of HTTP status
    /// - Parameters:
    ///   - kind: The kind of status the response is expected for
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func text(
        kind: HTTPResponse.Status.Kind,
        encoding: String.Encoding = .utf8,
        accept: HTTPField.MediaType? = .textPlain,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: nil,
            kind: kind,
            accept: accept,
            summary: summary,
            description: description(),
            content: .text(encoding)
        )
    }
    
    /// A data response for an HTTP status
    /// - Parameters:
    ///   - status: The status the response is expected for
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func data(
        _ status: HTTPResponse.Status,
        accept: HTTPField.MediaType? = .applicationOctetStream,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: status,
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .data
        )
    }
    
    /// A data response for an HTTP status code
    /// - Parameters:
    ///   - code: The code the response is expected for
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func data(
        code: Int,
        accept: HTTPField.MediaType? = .applicationOctetStream,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: HTTPResponse.Status(code: code),
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .data
        )
    }
    
    /// A data response for a kind of HTTP status
    /// - Parameters:
    ///   - kind: The kind of status the response is expected for
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func data(
        kind: HTTPResponse.Status.Kind,
        accept: HTTPField.MediaType? = .applicationOctetStream,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: nil,
            kind: kind,
            accept: accept,
            summary: summary,
            description: description(),
            content: .data
        )
    }
    
    /// A default response for any HTTP status, without expecting any content
    /// - Parameters:
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func `default`(
        accept: HTTPField.MediaType? = nil,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: nil,
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .empty
        )
    }
    
    /// A default response for any HTTP status, expecting JSON
    /// - Parameters:
    ///   - returning: The expected JSON object
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func defaultWithJSON(
        returning schema: Decodable.Type,
        accept: HTTPField.MediaType? = .applicationJSON,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: nil,
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .json(schema)
        )
    }
    
    /// A default response for any HTTP status, expecting a JSON dictionary
    /// - Parameters:
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func defaultWithJSONDictionary(
        accept: HTTPField.MediaType? = .applicationJSON,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: nil,
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .jsonDictionary
        )
    }
    
    /// A default response for any HTTP status, expecting text
    /// - Parameters:
    ///   - encoding: The expected string encoding
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func defaultWithText(
        encoding: String.Encoding = .utf8,
        accept: HTTPField.MediaType? = .textPlain,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: nil,
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .text(encoding)
        )
    }
    
    /// A default response for any HTTP status, expecting data
    /// - Parameters:
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    /// - Returns: The defined response
    public static func defaultWithData(
        accept: HTTPField.MediaType? = .applicationOctetStream,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Response {
        self.init(
            status: nil,
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .data
        )
    }
    
    /// A response for an HTTP status, not expecting any content
    /// - Parameters:
    ///   - status: The status the response is expected for
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    public init(
        _ status: HTTPResponse.Status,
        accept: HTTPField.MediaType? = nil,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(
            status: status,
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .empty
        )
    }
    
    /// A response for a kind of HTTP status, not expecting any content
    /// - Parameters:
    ///   - kind: The kind of status the response is expected for
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    public init(
        kind: HTTPResponse.Status.Kind,
        accept: HTTPField.MediaType? = nil,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(
            status: nil,
            kind: kind,
            accept: accept,
            summary: summary,
            description: description(),
            content: .empty
        )
    }
    
    /// A response for an HTTP status code, not expecting any content
    /// - Parameters:
    ///   - code: The code the response is expected for
    ///   - accept: The media type to send as the `Accept` header. If nil, nothing will be sent.
    ///   - summary: A short summary of the response
    ///   - description: A longer description of the response
    public init(
        code: Int,
        accept: HTTPField.MediaType? = nil,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(
            status: HTTPResponse.Status(code: code),
            kind: nil,
            accept: accept,
            summary: summary,
            description: description(),
            content: .empty
        )
    }
}
