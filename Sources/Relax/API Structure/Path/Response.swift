//
//  Response.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation

public struct Response: Sendable {
    let summary: String?
    let description: String?
    let httpStatus: HTTPStatus
    let content: [Header.ContentType: Payload]
    
    public enum Payload: @unchecked Sendable {
        case empty
        case bytes
        case json(_ type: any Decodable.Type)
        case text(_ encoding: String.Encoding = .utf8)
    }
    
    public enum HTTPStatus: Hashable, Sendable {
        public enum Range: Sendable {
            /// Informational: 100-199
            case information
            /// Success: 200-299
            case success
            /// Redirection: 300-399
            case redirection
            /// Client error: 400-499
            case clientError
            /// Server error: 500-599
            case serverError
        }
        case code(Int)
        case range(Range)
        case `default`
        
        // Success
        /// OK (200)
        public static let success = Self.code(200)
        /// Created (201)
        public static let created = Self.code(201)
        /// Accepted (202)
        public static let accepted = Self.code(202)
        /// No Content (204)
        public static let noContent = Self.code(204)
        
        // Client errors
        /// Bad Request (400)
        public static let badRequest = Self.code(400)
        /// Not Authorized (401)
        public static let notAuthorized = Self.code(401)
        /// Forbidden (403)
        public static let forbidden = Self.code(403)
        /// Not Found (404)
        public static let notFound = Self.code(404)
        /// Too Many Requests (429)
        public static let tooManyRequests = Self.code(429)
        
        // Server errors
        /// Internal Server Error (500)
        public static let internalServerError = Self.code(500)
        /// Bad Gateway (502)
        public static let badGateway = Self.code(502)
        /// Service Unavailable (503)
        public static let serviceUnavailable = Self.code(503)
        /// Gateway Timeout (504)
        public static let gatewayTimeout = Self.code(504)
    }
    
    internal static func contentType(for payload: Payload) -> Header.ContentType? {
        switch payload {
        case .empty: nil
        case .bytes: .applicationOctetStream
        case .json: .applicationJSON
        case .text: .textPlain
        }
    }
    
    internal init(
        _ status: HTTPStatus,
        summary: String? = nil,
        description: String? = nil,
        content: [Header.ContentType : Payload]
    ) {
        self.summary = summary
        self.description = description
        self.httpStatus = status
        self.content = content
    }
    
    public init(
        _ status: HTTPStatus = .success,
        payload: Payload,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        var content = [Header.ContentType: Payload]()
        if let contentType = Self.contentType(for: payload) {
            content[contentType] = payload
        }
        self.init(status, summary: summary, description: description(), content: content)
    }
    
    public init(
        _ status: HTTPStatus,
        summary: String? = nil,
        returning schema: any Decodable.Type,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(status, summary: summary, description: description(), content: [.applicationJSON: .json(schema)])
    }
        
    public init(
        _ status: HTTPStatus,
        summary: String? = nil,
        @Builder content: () -> [Header.ContentType: Payload],
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(status, summary: summary, description: description(), content: content())
    }
        
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> [Header.ContentType : Response.Payload] {
            [:]
        }
        
        public static func buildPartialBlock(
            first: [Header.ContentType : Response.Payload]
        ) -> [Header.ContentType : Response.Payload] {
            first
        }
        
        public static func buildPartialBlock(
            accumulated: [Header.ContentType : Response.Payload],
            next: [Header.ContentType : Response.Payload]
        ) -> [Header.ContentType : Response.Payload] {
            accumulated.merging(next, uniquingKeysWith: { _, new in new })
        }
        
        public static func buildExpression(_ expression: Content) -> [Header.ContentType : Response.Payload] {
            [expression.type: expression.payload]
        }
    }
    
    public struct Content: Sendable {
        let type: Header.ContentType
        let payload: Response.Payload
        
        public init(_ type: Header.ContentType, payload: Response.Payload) {
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
        /// - Parameter contentType: The expected content type, for reference only. Defaults to `application/octet-stream`.
        /// - Returns: Content with the content type specified and payload of `.bytes`.
        ///
        /// Unlike the other content types, the generated code will not attempt any decoding or validation and simply return the response as arbitrary `Data`.
        public static func data(_ contentType: Header.ContentType = .applicationOctetStream) -> Content {
            self.init(contentType, payload: .bytes)
        }
        
//        @resultBuilder
//        public enum Builder {
//            public static func buildBlock() -> [Content] {
//                []
//            }
//
//            public static func buildPartialBlock(
//                first: [Content]
//            ) -> [Content] {
//                first
//            }
//
//            public static func buildPartialBlock(
//                accumulated: [Content],
//                next: [Content]
//            ) -> [Content] {
//                accumulated + next
//            }
//
//            public static func buildExpression(_ expression: Content) -> [Content] {
//                [expression]
//            }
//
//            @available(*, unavailable)
//            public static func buildOptional(_ component: [Content]?) -> [Content] {
//                component ?? []
//            }
//
//            @available(*, unavailable)
//            public static func buildEither(first component: [Content]) -> [Content] {
//                component
//            }
//
//            @available(*, unavailable)
//            public static func buildEither(second component: [Content]) -> [Content] {
//                component
//            }
//
//            @available(*, unavailable)
//            public static func buildArray(_ components: [[Content]]) -> [Content] {
//                components.flatMap { $0 }
//            }
//
//            @available(*, unavailable)
//            public static func buildLimitedAvailability(_ component: [Content]) -> [Content] {
//                component
//            }
//        }
    }
}
