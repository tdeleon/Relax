//
//  HTTPField+Headers.swift
//  Relax
//
//  Created by Thomas De Leon on 5/16/26.
//

import Foundation
import HTTPTypes
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

//MARK: Authorization
extension HTTPField {
    /// An authorization header with the specified security scheme
    /// - Parameters:
    ///   - scheme: The scheme to use
    ///   - value: The authorization value
    /// - Returns: An Authorization header with the value formatted "<scheme> <value>"
    public static func authorization(_ scheme: SecurityScheme.HTTPAuthenticationScheme, value: String) -> Self {
        HTTPField(name: .authorization, value: "\(scheme) \(value)")
    }
    
    /// An Authorization header with Basic security scheme using an encoded username and password
    /// - Parameters:
    ///   - user: The username to send
    ///   - password: The password to send
    /// - Returns: An Authorization header with the value "Basic <base64 encoded user:password>"
    ///
    /// The username and password will be base 64 encoded.
    public static func authorizationBasic(user: String, password: String) -> Self {
        let encoded = Data("\(user):\(password)".utf8).base64EncodedString()
        return HTTPField.authorization(.basic, value: encoded)
    }
}

//MARK: - Cache Control
extension HTTPField {
    public enum CacheControlDirective: Sendable, Hashable {
        /// Directive `no-cache`
        case noCache
        /// Directive `no-store`
        case noStore
        /// Directive `max-age=<seconds>`
        case maxAge(seconds: Int)
        /// Directive `max-stale=<seconds>`
        case maxStale(seconds: Int)
        /// Directive `min-fresh=<seconds>`
        case minFresh(seconds: Int)
        /// Directive `no-transform`
        case noTransform
        /// Directive `only-if-cached`
        case onlyIfCached
        /// Directive `stale-if-error`
        case staleIfError
        
        /// The value used in the HTTPField header
        public var fieldValue: String {
            switch self {
            case .noCache: "no-cache"
            case .noStore: "no-store"
            case .maxAge(let seconds): "max-age=\(seconds)"
            case .maxStale(let seconds): "max-stale=\(seconds)"
            case .minFresh(let seconds): "min-fresh=\(seconds)"
            case .noTransform: "no-transform"
            case .onlyIfCached: "only-if-cached"
            case .staleIfError: "stale-if-error"
            }
        }
    }
    
    /// Cache-Control header
    /// - Parameter value: The value to specify for the header
    /// - Returns: An HTTPField with the name `Cache-Control` and value specified. There is no formatting applied to the string provided for `value`.
    public static func cacheControl(_ value: String) -> HTTPField {
        HTTPField(name: .cacheControl, value: value)
    }
    
    /// Cache Control header with a directive
    /// - Parameter directive: Directives to specify
    /// - Returns: An `HTTPField` header whose name is `Cache-Control` and whose value is a directive.
    public static func cacheControl(_ directive: CacheControlDirective) -> HTTPField {
        cacheControl([directive])
    }
    
    /// Cache Control header with directives
    /// - Parameter directives: Directives to specify
    /// - Returns: An `HTTPField` header whose name is `Cache-Control` and whose value is a comma separated list of directives.
    public static func cacheControl(_ directives: [CacheControlDirective]) -> HTTPField {
        HTTPField.cacheControl(directives.map(\.fieldValue).joined(separator: ", "))
    }
}

//MARK: - Content/Media Type
extension HTTPField {
    
    /// Media Types for use  in headers such as `accept` or `content-type`.
    ///
    /// Common types are pre-defined a sa convenience; others can be created as needed.
    /// For a complete list of all types, see: https://datatracker.ietf.org/doc/html/rfc6838
    public struct MediaType: CustomStringConvertible, Hashable, Sendable {
        /// The type
        public let type: String
        /// The subtype
        public let subtype: String
        /// Parameter list of the media type
        public let parameters: [String: String]
        
        /// Create a media type from a type/subtype and optional parameters
        /// - Parameters:
        ///   - type: The type
        ///   - subtype: The subtype
        ///   - parameters: Parameters to include
        public init(_ type: String, _ subtype: String, parameters: [String: String] = [:]) {
            self.type = type
            self.subtype = subtype
            self.parameters = parameters
        }
        
        /// A formatted string description of the media type, for use in HTTP header values.
        ///
        /// The media type will be formatted as `<type>/<subtype>;<parameter=value>`
        public var description: String {
            let base = "\(type)/\(subtype)"
            let parameters = parameters.map { "\($0.key)=\($0.value)" }
            return ([base] + parameters).joined(separator: ";")
        }
        
        /// Media type `application/json`
        public static let applicationJSON = Self("application", "json")
        /// Content type of `application/octet-stream`
        public static let applicationOctetStream = Self("application", "octet-stream")
        /// Content type of `application/x-www-form-urlencoded`
        public static let applicationFormURLEncoded = Self("application", "x-www-form-urlencoded")
        /// Content type of `application/pdf`
        public static let applicationPDF = Self("application", "pdf")
        /// Media type `text/plain`
        public static let textPlain = Self("text", "plain")
        /// Content type of `text/html`
        public static let textHTML = Self("text", "html")
        /// Content type of `image/jpeg`
        public static let imageJPEG = Self("image", "jpeg")
        /// Content type of `image/png`
        public static let imagePNG = Self("image", "png")
    }
    
    /// An Accept header with the specified value
    /// - Parameter value: The value to send
    /// - Returns: An `HTTPField` header  with the name `Accept` and specified value.
    public static func accept(_ value: String) -> HTTPField {
        HTTPField(name: .accept, value: value)
    }
    
    /// An Accept header with the specified media type
    /// - Parameter type: The media type value to specify
    /// - Returns: An `HTTPField` header whose name `Accept` and whose value is the media type specified.
    ///
    /// The value will be formatted `<type>/<subtype>;[parameter=value]`.
    public static func accept(_ type: MediaType) -> HTTPField {
        HTTPField.accept(type.description)
    }
    
    /// An Accept header with the specified media type
    /// - Parameter types: The media type values to specify
    /// - Returns: An `HTTPField` header with the name `Accept` and whose value is the media types specified.
    ///
    /// The value will be formatted as a comma sepated list of media types; each media type will be formatted as
    /// `<type>/<subtype>;[parameter=value]`.
    public static func accept(_ types: [MediaType]) -> HTTPField {
        HTTPField.accept(types.map(\.description).joined(separator: ", "))
    }
    
    #if canImport(UniformTypeIdentifiers)

    /// An Accept header with a Uniform Type.
    /// - Parameter utType: The Uniform Type value to specify
    /// - Returns: An `HTTPField` whose name is `Accept` and whose value is the `preferredMIMEType` property of the provided type. If there is
    ///            no `preferredMIMEType` property on the type, then nil is returned.
    /// - Note: Only available on iOS, macOS, watchOS, and tvOS.
    public static func accept(_ utType: UTType) -> HTTPField? {
        guard let mime = utType.preferredMIMEType else { return nil }
        return HTTPField.accept(mime)
    }
    
    /// An Accept header with a list of Uniform Types
    /// - Parameter utTypes: The Uniform Type values to specify
    /// - Returns: An `HTTPField` whose name is `Accept` and whose value is a comma separated list of the `preferredMIMEType` properties of the
    ///            provided types. If none of the provided types have a `preferredMIMEType`, then nil is returned.
    /// - Note: Only available on iOS, macOS, watchOS, and tvOS.
    public static func accept(_ utTypes: [UTType]) -> HTTPField? {
        let types = utTypes.compactMap(\.preferredMIMEType).joined(separator: ", ")
        guard !types.isEmpty else { return nil }
        return HTTPField.accept(types)
    }
    #endif
    
    /// A Content-Type header
    /// - Parameter value: The content type value
    /// - Returns: An `HTTPField` header with name `content-type` and the value specified.
    public static func contentType(_ value: String) -> HTTPField {
        HTTPField(name: .contentType, value: value)
    }
    
    /// A Content-Type header using a typed MediaType value.
    ///
    /// Use this overload when you want to construct the Content-Type header from a strongly-typed
    /// MediaType rather than a raw string. The provided MediaType is formatted as
    /// "<type>/<subtype>;[parameter=value]" and used as the header value.
    ///
    /// - Parameter mediaType: The MediaType describing the body’s media type and any parameters.
    /// - Returns: An `HTTPField` with the name `Content-Type` and the formatted media type as its value.
    public static func contentType(_ mediaType: MediaType) -> Self {
        HTTPField.contentType(mediaType.description)
    }
    
    #if canImport(UniformTypeIdentifiers)
    /// A Content-Type header using a typed MediaType value.
    ///
    /// Use this overload when you want to construct the Content-Type header from a strongly-typed
    /// MediaType rather than a raw string. The provided MediaType is formatted as
    /// "<type>/<subtype>;[parameter=value]" and used as the header value.
    /// 
    ///- Parameter utType: The UniformType value to specify
    /// - Returns: An `HTTPField` with the name `Content-Type` and the formatted media type as its value.
    ///
    /// - Note: Only available on iOS, macOS, watchOS, and tvOS.
    public static func contentType(_ utType: UTType) -> HTTPField? {
        guard let mime = utType.preferredMIMEType else { return nil }
        return contentType(mime)
    }
    
    /// A Content-Type header using a typed MediaType value.
    ///
    /// Use this overload when you want to construct the Content-Type header from a strongly-typed
    /// MediaType rather than a raw string. The provided MediaType is formatted as
    /// "<type>/<subtype>;[parameter=value]" and used as the header value.
    ///
    /// - Parameter utTypes: The MediaType describing the body’s media type and any parameters.
    /// - Returns: An `HTTPField` header whose name is `Content-Type` and whose value is a comma separated list of the formatted.
    ///
    /// - Note: Only available on iOS, macOS, watchOS, and tvOS.
    public static func contentType(_ utTypes: [UTType]) -> HTTPField? {
        let types = utTypes.compactMap(\.preferredMIMEType).joined(separator: ", ")
        guard !types.isEmpty else { return nil }
        return contentType(types)
    }
    #endif
}

//MARK: - Accept Language
extension HTTPField {
    /// An Accept-Language header with the provided string value.
    ///
    /// - Parameter value: A raw Accept-Language header value composed of one or more BCP 47 language identifiers, optionally including q-values to
    ///                    express preference. For example, "en-US" or "en-US, en;q=0.9, fr-CA;q=0.8".
    /// - Returns: An `HTTPField` header whose name is `Accept-Language` and whose value is the provided string.
    public static func acceptLanguage(_ value: String) -> HTTPField {
        HTTPField(name: .acceptLanguage, value: value)
    }
    
    
    /// An Accept-Language header with provided language.
    ///
    /// - Parameter language: The language to specify
    /// - Returns: An `HTTPField` header whose name is `Accept-Language` and whose value is the `maximalIdentifier` property of the
    ///            provided language.
    public static func acceptLanguage(_ language: Locale.Language) -> HTTPField {
        HTTPField.acceptLanguage(language.maximalIdentifier)
    }
    
    /// An Accept-Language header with provided languages.
    ///
    /// - Parameter languages: The languages to specify
    /// - Returns: An `HTTPField` header whose name is `Accept-Language` and whose value is a comma separated list of the
    ///            `maximalIdentifier` properties of the specified languages.
    public static func acceptLanguage(_ languages: [Locale.Language]) -> HTTPField {
        HTTPField.acceptLanguage(languages.map(\.maximalIdentifier).joined(separator: ", "))
    }
}
