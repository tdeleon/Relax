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
    let content: [HTTPField.MediaType: Payload]
    
    var responseType: ResponseType {
        if let httpStatus {
            .status(httpStatus)
        } else if let kind {
            .kind(kind)
        } else {
            .defaultType
        }
    }
    
    public enum ResponseType: Sendable, Hashable {
        case status(HTTPResponse.Status)
        case kind(HTTPResponse.Status.Kind)
        case defaultType
    }
    
    public enum Payload: @unchecked Sendable {
        case empty
        case bytes
        case json(_ type: any Decodable.Type)
        case text(_ encoding: String.Encoding = .utf8)
        
        internal var content: [HTTPField.MediaType: Payload] {
            switch self {
            case .empty: [:]
            case .bytes: [.applicationOctetStream: self]
            case .json: [.applicationJSON: self]
            case .text: [.textPlain: self]
            }
        }
    }
    
    internal init(
        status: HTTPResponse.Status?,
        kind: HTTPResponse.Status.Kind? = nil,
        summary: String?,
        description: String?,
        content: [HTTPField.MediaType : Payload]
    ) {
        self.summary = summary
        self.description = description
        self.httpStatus = status
        self.kind = kind ?? status?.kind
        self.content = content
    }
    
    public init(
        _ status: HTTPResponse.Status,
        payload: Payload,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(status: status, summary: summary, description: description(), content: payload.content)
    }
    
    public init(
        code: Int,
        payload: Payload,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(
            status: HTTPResponse.Status(code: code),
            summary: summary,
            description: description(),
            content: payload.content
        )
    }
    
    public init(
        kind: HTTPResponse.Status.Kind,
        payload: Payload,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(
            status: nil,
            kind: kind,
            summary: summary,
            description: description(),
            content: payload.content
        )
    }
    
    public init(
        _ status: HTTPResponse.Status,
        summary: String? = nil,
        returning schema: any Decodable.Type,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(
            status: status,
            summary: summary,
            description: description(),
            content: Payload.json(schema).content
        )
    }
    
    public init(
        code: Int,
        summary: String? = nil,
        returning schema: any Decodable.Type,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(
            status: HTTPResponse.Status(code: code),
            summary: summary,
            description: description(),
            content: Payload.json(schema).content
        )
    }
    
    public init(
        kind: HTTPResponse.Status.Kind,
        summary: String? = nil,
        returning schema: any Decodable.Type,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(
            status: nil,
            kind: kind,
            summary: summary,
            description: description(),
            content: Payload.json(schema).content
        )
    }
        
    public init(
        _ status: HTTPResponse.Status,
        summary: String? = nil,
        @Builder content: () -> [HTTPField.MediaType: Payload],
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(status: status, summary: summary, description: description(), content: content())
    }
    
    public init(
        code: Int,
        summary: String? = nil,
        @Builder content: () -> [HTTPField.MediaType: Payload],
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(
            status: HTTPResponse.Status(code: code),
            summary: summary,
            description: description(),
            content: content()
        )
    }
    
    public init(
        kind: HTTPResponse.Status.Kind,
        summary: String? = nil,
        @Builder content: () -> [HTTPField.MediaType: Payload],
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(
            status: nil,
            kind: kind,
            summary: summary,
            description: description(),
            content: content()
        )
    }
    
    public static func `default`(
        payload: Payload,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Self {
        self.init(status: nil, summary: summary, description: description(), content: payload.content)
    }
    
    public static func `default`(
        _ summary: String? = nil,
        returning schema: any Decodable.Type,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Self {
        self.init(status: nil, summary: summary, description: description(), content: Payload.json(schema).content)
    }
    
    public static func `default`(
        summary: String? = nil,
        @Builder content: () -> [HTTPField.MediaType: Payload],
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Self {
        self.init(
            status: nil,
            summary: summary,
            description: description(),
            content: content()
        )
    }
        
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> [HTTPField.MediaType : Response.Payload] {
            [:]
        }
        
        public static func buildPartialBlock(
            first: [HTTPField.MediaType : Response.Payload]
        ) -> [HTTPField.MediaType : Response.Payload] {
            first
        }
        
        public static func buildPartialBlock(
            accumulated: [HTTPField.MediaType : Response.Payload],
            next: [HTTPField.MediaType : Response.Payload]
        ) -> [HTTPField.MediaType : Response.Payload] {
            accumulated.merging(next, uniquingKeysWith: { _, new in new })
        }
        
        public static func buildExpression(_ expression: Content) -> [HTTPField.MediaType : Response.Payload] {
            [expression.type: expression.payload]
        }
    }
    
    public struct Content: Sendable {
        let type: HTTPField.MediaType
        let payload: Response.Payload
        
        public init(_ type: HTTPField.MediaType, payload: Response.Payload) {
            self.type = type
            self.payload = payload
        }
        
        /// Expected content of a JSON Decodable type
        /// - Parameter schema: The expected type of object
        /// - Returns: Content with a content type of `application/json` and expected payload of the specified `Decodable` type.
        ///
        /// The generated code will set an `Accept` header of `application/JSON` and attempt to decode the response, returning the `schema` type.
        public static func json(_ schema: any Decodable.Type) -> Content {
            self.init(.applicationJSON, payload: .json(schema))
        }
        
        /// Expected content of an aribtrary JSON Dictionary
        /// - Returns: Content with content type of `application/json` and expected payload type of `bytes`.
        ///
        /// The generated code will set an `Accept` header of `application/JSON` and attempt to serialize the response using `JSONSerialization`,
        /// returning `[String: Any]`.
        public static func jsonDictionary() -> Content {
            self.init(.applicationJSON, payload: .bytes)
        }
        
        /// Expected content of plain text
        /// - Parameter encoding: The encoding type. Defaults to `.utf8`.
        /// - Returns: Content with a content type of `text/plain` and expected payload of the type `.text` with the given encoding.
        ///
        /// The generated code witll set an `Accept` header of `text/plain`, returning a `String` using the specified encoding.
        public static func text(_ encoding: String.Encoding = .utf8) -> Content {
            self.init(.textPlain, payload: .text(encoding))
        }
        
        /// Expected content of Data
        /// - Parameter mediaType: The expected media type, for reference only. Defaults to `application/octet-stream`.
        /// - Returns: Content with the content type specified and payload of `.bytes`.
        ///
        /// Unlike the other content types, the generated code will not attempt any decoding or validation and simply return the response as arbitrary `Data`.
        public static func data(_ mediaType: HTTPField.MediaType = .applicationOctetStream) -> Content {
            self.init(mediaType, payload: .bytes)
        }
    }
}
