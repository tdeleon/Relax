//
//  Path.swift
//  Relax
//
//  Created by Thomas De Leon on 3/3/26.
//

import Foundation

public struct Tag: Hashable, Sendable {
    public let name: String
    public let description: String?
    
    public init(_ name: String, description: String?) {
        self.name = name
        self.description = description
    }
}

public struct Path: Sendable {
    public let path: String
    public let summary: String?
    public let tags: [Tag]
    public let description: String?
    public let operations: [Request.HTTPMethod: Operation]
    public let servers: [Server]
    public let parameters: [Parameter]
    
    public init(
        _ path: String,
        summary: String? = nil,
        tags: [Tag] = [],
        @OperationsBuilder operations: () -> [Request.HTTPMethod: Operation],
        @Parameter.Builder parameters: () -> [Parameter] = { [] },
        @ServersBuilder servers: () -> [Server] = { [] },
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.path = path
        self.summary = summary
        self.tags = tags
        self.servers = servers()
        self.operations = operations()
        self.parameters = parameters()
        self.description = description()
    }
    
    @resultBuilder
    public enum OperationsBuilder {
        public static func buildBlock() -> [Request.HTTPMethod: Path.Operation] {
            [:]
        }
        
        public static func buildPartialBlock(
            first: [Request.HTTPMethod: Path.Operation]
        ) -> [Request.HTTPMethod: Path.Operation] {
            first
        }
        
        public static func buildPartialBlock(
            accumulated: [Request.HTTPMethod: Path.Operation],
            next: [Request.HTTPMethod: Path.Operation]
        ) -> [Request.HTTPMethod: Path.Operation] {
            accumulated.merging(next) { _, new in new }
        }
        
        public static func buildExpression(_ expression: Path.Operation) -> [Request.HTTPMethod: Path.Operation] {
            [expression.method: expression]
        }
    }
    
    public struct Operation: Sendable {
        public let method: Request.HTTPMethod
        public let id: String?
        public let summary: String?
        public let description: String?
        public let tags: [Tag]
        public let parameters: [Parameter]
        public let responses: [Response.HTTPStatus: Response]
        

        
        public init(
            _ method: Request.HTTPMethod,
            id: StaticString? = nil,
            summary: String? = nil,
            tags: [Tag] = [],
            @ResponsesBuilder responses: () -> [Response.HTTPStatus : Response],
            @Parameter.Builder parameters: () -> [Parameter] = { [] },
            @DescriptionBuilder description: () -> String? = { nil }
        ) {
            self.method = method
            self.id = id == nil ? nil : "\(id!)"
            self.tags = tags
            self.summary = summary
            self.description = description()
            self.parameters = parameters()
            self.responses = responses()
        }
        
        @resultBuilder
        public enum ResponsesBuilder {
            public static func buildBlock() -> [Response.HTTPStatus: Response] {
                [:]
            }
            
            public static func buildPartialBlock(
                first: [Response.HTTPStatus : Response]
            ) -> [Response.HTTPStatus : Response] {
                first
            }
            
            public static func buildPartialBlock(
                accumulated: [Response.HTTPStatus : Response],
                next: [Response.HTTPStatus : Response]
            ) -> [Response.HTTPStatus : Response] {
                accumulated.merging(next) { _, new in new }
            }
            
            public static func buildExpression(_ expression: Response) -> [Response.HTTPStatus : Response] {
                [expression.httpStatus: expression]
            }
        }
    }
}

public struct Response: Sendable {
    let summary: String?
    let description: String?
    let httpStatus: HTTPStatus
    let content: [Header.ContentType: Payload]
    
    public enum Payload: @unchecked Sendable {
        case empty
        case bytes
        case json(any Decodable.Type)
        case text(encoding: String.Encoding = .utf8)
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
        summary: String? = nil,
        payload: Payload,
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
        @Builder content: () -> [Header.ContentType: Payload],
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(status, summary: summary, description: description(), content: content())
    }
    
    public init(
        _ status: HTTPStatus,
        summary: String? = nil,
        returning schema: any Decodable.Type,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.init(status, summary: summary, description: description(), content: [.applicationJSON: .json(schema)])
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
            self.init(.textPlain, payload: .text(encoding: encoding))
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

public struct Parameter: Sendable {
    public enum Location: Sendable {
        case path
        case query
        case queryString
        case header
        case cookie
    }
    
    public enum Style: Sendable {
        public enum Path {
            case simple
            case label
            case matrix
        }
        
        public enum Query: Sendable {
            case form
            case spaceDelimited
            case pipeDelimited
            case deepObject
        }
        
        public enum Cookie: Sendable {
            case cookie
            case form
        }
    }
    
    let name: String
    let location: Location
    let description: String?
    let required: Bool
    let type: Any.Type
    
    internal init(
        _ name: String,
        ofType type: Any.Type,
        in location: Location,
        description: String? = nil,
        required: Bool = false
    ) {
        self.name = name
        self.location = location
        self.description = description
        self.required = required
        self.type = type
    }
    
    public static func path<T: CustomStringConvertible>(
        _ name: String,
        ofType type: T.Type,
        style: Style.Path = .simple,
        description: String? = nil
    ) -> Parameter {
        self.init(name, ofType: type, in: .path, description: description, required: true)
    }
    
    public static func query<T: CustomStringConvertible>(
        _ name: String,
        ofType type: T.Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required)
    }
    
    public static func query<T: CustomStringConvertible>(
        _ name: String,
        ofType type: [T].Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required)
    }
    
    public static func query<T: RawRepresentable>(
        _ name: String,
        ofType type: T.Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter where T.RawValue == CustomStringConvertible {
        self.init(name, ofType: type, in: .query, description: description, required: required)
    }
    
    public static func query(
        _ name: String,
        ofType type: [String: any CustomStringConvertible].Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required)
    }
    
    public static func query<T: Encodable>(
        _ name: String,
        ofObjectType type: T.Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required)
    }
    
    public static func queryString(
        _ name: String,
        contentType: Header.ContentType = .applicationFormURLEncoded,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: Header.ContentType.self, in: .queryString, required: required)
    }
    
    public static func header<T: LosslessStringConvertible>(
        _ name: String,
        valueType: T.Type,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType.self, in: .header, description: description, required: required)
    }
    
    public static func header<T: LosslessStringConvertible>(
        _ name: String,
        valueType: [T].Type,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType.self, in: .header, description: description, required: required)
    }
    
    public static func cookie<T: LosslessStringConvertible>(
        _ name: String,
        valueType: T.Type,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType, in: .cookie, description: description, required: required)
    }
    
    public static func cookie<T: LosslessStringConvertible>(
        _ name: String,
        valueType: [T].Type,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType, in: .cookie, description: description, required: required)
    }
    
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> [Parameter] {
            []
        }
        
        public static func buildPartialBlock(first: [Parameter]) -> [Parameter] {
            first
        }
        
        public static func buildPartialBlock(accumulated: [Parameter], next: [Parameter]) -> [Parameter] {
            accumulated + next
        }
        
        public static func buildExpression(_ expression: Parameter) -> [Parameter] {
            [expression]
        }
    }
}
