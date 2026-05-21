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
        case bytes
        case json(_ type: any Decodable.Type)
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
            content: .bytes
        )
    }
    
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
            content: .bytes
        )
    }
    
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
            content: .bytes
        )
    }
    
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
            content: .bytes
        )
    }
    
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
            content: .bytes
        )
    }
    
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
            content: .bytes
        )
    }
    
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
            content: .bytes
        )
    }
    
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
            content: .bytes
        )
    }
    
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
    
//    public init(
//        _ status: HTTPResponse.Status,
//        payload: Payload = .empty,
//        summary: String? = nil
//    ) {
//        self.init(status: status, summary: summary, description: nil, content: payload.content)
//    }
//    
//    public init(
//        _ status: HTTPResponse.Status,
//        payload: Payload = .empty,
//        summary: String? = nil,
//        @DescriptionBuilder description: () -> String?
//    ) {
//        self.init(status: status, summary: summary, description: description(), content: payload.content)
//    }
//    
//    public init(
//        _ status: HTTPResponse.Status,
//        summary: String? = nil,
//        returning schema: Decodable.Type,
//        @DescriptionBuilder description: () -> String? = { nil }
//    ) {
//        self.init(
//            status: status,
//            summary: summary,
//            description: description(),
//            content: Payload.json(schema).content
//        )
//    }
//    
//    public init(
//        _ status: HTTPResponse.Status,
//        summary: String? = nil,
//        @Builder content: () -> [HTTPField.MediaType: Payload],
//        @DescriptionBuilder description: () -> String? = { nil }
//    ) {
//        self.init(status: status, summary: summary, description: description(), content: content())
//    }
//    
//    public init(
//        code: Int,
//        payload: Payload = .empty,
//        summary: String? = nil,
//        @DescriptionBuilder description: () -> String? = { nil }
//    ) {
//        self.init(
//            status: HTTPResponse.Status(code: code),
//            summary: summary,
//            description: description(),
//            content: payload.content
//        )
//    }
//    
//    public init(
//        kind: HTTPResponse.Status.Kind,
//        payload: Payload = .empty,
//        summary: String? = nil,
//        @DescriptionBuilder description: () -> String? = { nil }
//    ) {
//        self.init(
//            status: nil,
//            kind: kind,
//            summary: summary,
//            description: description(),
//            content: payload.content
//        )
//    }
//    
//    public init(
//        code: Int,
//        summary: String? = nil,
//        returning schema: Decodable.Type,
//        @DescriptionBuilder description: () -> String? = { nil }
//    ) {
//        self.init(
//            status: HTTPResponse.Status(code: code),
//            summary: summary,
//            description: description(),
//            content: Payload.json(schema).content
//        )
//    }
//    
//    public init(
//        kind: HTTPResponse.Status.Kind,
//        summary: String? = nil,
//        returning schema: Decodable.Type,
//        @DescriptionBuilder description: () -> String? = { nil }
//    ) {
//        self.init(
//            status: nil,
//            kind: kind,
//            summary: summary,
//            description: description(),
//            content: Payload.json(schema).content
//        )
//    }
//        
//    public init(
//        code: Int,
//        summary: String? = nil,
//        @Builder content: () -> [HTTPField.MediaType: Payload],
//        @DescriptionBuilder description: () -> String? = { nil }
//    ) {
//        self.init(
//            status: HTTPResponse.Status(code: code),
//            summary: summary,
//            description: description(),
//            content: content()
//        )
//    }
//    
//    public init(
//        kind: HTTPResponse.Status.Kind,
//        summary: String? = nil,
//        @Builder content: () -> [HTTPField.MediaType: Payload]
//    ) {
//        self.init(
//            status: nil,
//            kind: kind,
//            summary: summary,
//            description: nil,
//            content: content()
//        )
//    }
//    
//    public init(
//        kind: HTTPResponse.Status.Kind,
//        summary: String? = nil,
//        @Builder content: () -> [HTTPField.MediaType: Payload],
//        @DescriptionBuilder description: () -> String
//    ) {
//        self.init(
//            status: nil,
//            kind: kind,
//            summary: summary,
//            description: description(),
//            content: content()
//        )
//    }
//    
//    public static func `default`(
//        payload: Payload,
//        summary: String? = nil,
//        @DescriptionBuilder description: () -> String? = { nil }
//    ) -> Self {
//        self.init(status: nil, summary: summary, description: description(), content: payload.content)
//    }
//    
//    public static func `default`(
//        _ summary: String? = nil,
//        returning schema: Decodable.Type,
//        @DescriptionBuilder description: () -> String? = { nil }
//    ) -> Self {
//        self.init(status: nil, summary: summary, description: description(), content: Payload.json(schema).content)
//    }
//    
//    public static func `default`(
//        summary: String? = nil,
//        @Builder content: () -> [HTTPField.MediaType: Payload],
//        @DescriptionBuilder description: () -> String? = { nil }
//    ) -> Self {
//        self.init(
//            status: nil,
//            summary: summary,
//            description: description(),
//            content: content()
//        )
//    }
        
//    @resultBuilder
//    public enum Builder {
//        public static func buildBlock() -> [HTTPField.MediaType : Response.Payload] {
//            [:]
//        }
//        
//        public static func buildPartialBlock(
//            first: [HTTPField.MediaType : Response.Payload]
//        ) -> [HTTPField.MediaType : Response.Payload] {
//            first
//        }
//        
//        public static func buildPartialBlock(
//            accumulated: [HTTPField.MediaType : Response.Payload],
//            next: [HTTPField.MediaType : Response.Payload]
//        ) -> [HTTPField.MediaType : Response.Payload] {
//            accumulated.merging(next, uniquingKeysWith: { _, new in new })
//        }
//        
//        public static func buildExpression(_ expression: Content) -> [HTTPField.MediaType : Response.Payload] {
//            [expression.type: expression.payload]
//        }
//    }
    
//    public struct Content: Sendable {
//        let type: HTTPField.MediaType
//        let payload: Response.Payload
//        
//        public init(_ type: HTTPField.MediaType, payload: Response.Payload) {
//            self.type = type
//            self.payload = payload
//        }
//        
//        /// Expected content of a JSON Decodable type
//        /// - Parameter schema: The expected type of object
//        /// - Returns: Content with a content type of `application/json` and expected payload of the specified `Decodable` type.
//        ///
//        /// The generated code will set an `Accept` header of `application/JSON` and attempt to decode the response, returning the `schema` type.
//        public static func json(_ schema: any Decodable.Type) -> Content {
//            self.init(.applicationJSON, payload: .json(schema))
//        }
//        
//        /// Expected content of an aribtrary JSON Dictionary
//        /// - Returns: Content with content type of `application/json` and expected payload type of `bytes`.
//        ///
//        /// The generated code will set an `Accept` header of `application/JSON` and attempt to serialize the response using `JSONSerialization`,
//        /// returning `[String: Any]`.
//        public static func jsonDictionary() -> Content {
//            self.init(.applicationJSON, payload: .bytes)
//        }
//        
//        /// Expected content of plain text
//        /// - Parameter encoding: The encoding type. Defaults to `.utf8`.
//        /// - Returns: Content with a content type of `text/plain` and expected payload of the type `.text` with the given encoding.
//        ///
//        /// The generated code witll set an `Accept` header of `text/plain`, returning a `String` using the specified encoding.
//        public static func text(_ encoding: String.Encoding = .utf8) -> Content {
//            self.init(.textPlain, payload: .text(encoding))
//        }
//        
//        /// Expected content of Data
//        /// - Parameter mediaType: The expected media type, for reference only. Defaults to `application/octet-stream`.
//        /// - Returns: Content with the content type specified and payload of `.bytes`.
//        ///
//        /// Unlike the other content types, the generated code will not attempt any decoding or validation and simply return the response as arbitrary `Data`.
//        public static func data(_ mediaType: HTTPField.MediaType = .applicationOctetStream) -> Content {
//            self.init(mediaType, payload: .bytes)
//        }
//    }
}
