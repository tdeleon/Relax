//
//  HTTPFieldAuthorizationTests.swift
//  Relax
//
//  Created by Thomas De Leon on 5/17/26.
//

import Foundation
import Testing
import HTTPTypes
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

@testable import Relax

struct HTTPFieldHeadersTests {
    static let securitySchemes: [SecurityScheme.HTTPAuthenticationScheme] = [
        .basic,
        .bearer,
        .concealed,
        .digest,
        .dpop,
        .gnap,
        .hoba,
        .negotiate,
        .oauth,
        .privateToken,
        .scramSHA1,
        .scramSHA256,
        .vapid
    ]
    
    static let mediaTypes: [HTTPField.MediaType] = [
        .applicationJSON,
        .applicationOctetStream,
        .applicationFormURLEncoded,
        .applicationPDF,
        .textPlain,
        .textHTML,
        .imageJPEG,
        .imagePNG
    ]
    
    static let directives: [HTTPField.CacheControlDirective] = [
        .noCache,
        .noStore,
        .maxAge(seconds: 10),
        .maxStale(seconds: 10),
        .minFresh(seconds: 10),
        .noTransform,
        .onlyIfCached,
        .staleIfError
    ]
    
    //MARK: - Authorization
    @Test(arguments: Self.securitySchemes)
    func `Authorization header`(scheme: SecurityScheme.HTTPAuthenticationScheme) async throws {
        let value = "value"
        let header = HTTPField.authorization(scheme, value: value)
        #expect(header.name == HTTPField.Name.authorization)
        #expect(header.value == "\(scheme.rawValue) \(value)")
    }

    @Test
    func `Basic authorization includes base64 encoded username & password`() async throws {
        let username = "someuser"
        let password = "S0m3P@ssw0rd"
        let encoded = Data("\(username):\(password)".utf8).base64EncodedString()
        
        let header = HTTPField.authorizationBasic(user: username, password: password)
        #expect(header.name == .authorization)
        #expect(header.value == "Basic \(encoded)")
    }

    //MARK: - Cache Control
    @Test func `Cache control with string value`() async throws {
        let value = "string-value"
        let field = HTTPField.cacheControl(value)
        
        #expect(field.name == HTTPField.Name.cacheControl)
        #expect(field.value == value)
    }

    @Test(arguments: directives)
    func `Cache control with a directive`(directive: HTTPField.CacheControlDirective) async throws {
        let field = HTTPField.cacheControl(directive)
        #expect(field.name == HTTPField.Name.cacheControl)
        #expect(field.value == directive.fieldValue)
    }
    
    @Test func `Cache control with multiple directives`() async throws {
        let directives: [HTTPField.CacheControlDirective] = [.noCache, .maxAge(seconds: 30)]
        let field = HTTPField.cacheControl(directives)
        #expect(field.name == HTTPField.Name.cacheControl)
        #expect(field.value == directives.map(\.fieldValue).joined(separator: ", "))
    }

    //MARK: - Media Type
    @Test func `Media type description`() async throws {
        let type = "application"
        let subtype = "test"
        let mediaType = HTTPField.MediaType(type, subtype)
        #expect(mediaType.type == type)
        #expect(mediaType.subtype == subtype)
        #expect(mediaType.description == "\(type)/\(subtype)")
    }
    
    @Test func `Media type description with parameters`() async throws {
        let type = "application"
        let subtype = "test"
        let parameters = [("first","value1"), ("second","value2")]
        let expectedParameters = parameters.map { "\($0.0)=\($0.1)" }.joined(separator: ";")
        let mediaType = HTTPField.MediaType(type, subtype, parameters: parameters)
        #expect(mediaType.type == type)
        #expect(mediaType.subtype == subtype)
        #expect(mediaType.description == "\(type)/\(subtype);\(expectedParameters)")
    }
    
    @Test func `Media type Equatable & Hashable conformance`() async throws {
        let first = HTTPField.MediaType("type", "subtype", parameters: [("param", "value")])
        let copy = first
        let second = HTTPField.MediaType("othertype", "othersubtype", parameters: [("param", "value")])
        
        #expect(first == copy)
        #expect(first.hashValue == copy.hashValue)
        #expect(first != second)
        #expect(first.hashValue != second.hashValue)
    }
    
    @Test func `Accept header with string value`() async throws {
        let value = "some/mediatype"
        let header = HTTPField.accept(value)
        #expect(header.name == .accept)
        #expect(header.value == value)
    }
    
    @Test(arguments: mediaTypes) func `Accept header with media type`(mediaType: HTTPField.MediaType) async throws {
        let header = HTTPField.accept(mediaType)
        #expect(header.name == .accept)
        #expect(header.value == mediaType.description)
    }
    
    @Test func `Accept header with multiple media types`() async throws {
        let types: [HTTPField.MediaType] = [.applicationJSON, .textPlain, .imagePNG]
        let header = HTTPField.accept(types)
        #expect(header.name == .accept)
        #expect(header.value == types.map(\.description).joined(separator: ", "))
    }
    
    #if canImport(UniformTypeIdentifiers)
    @Test func `Accept header with uniform type identifier`() async throws {
        let type = UTType.json
        let header = HTTPField.accept(type)
        #expect(header?.name == .accept)
        #expect(header?.value == type.preferredMIMEType)
    }
    
    @Test func `Accept header with uniform type identifiers`() async throws {
        let types: [UTType] = [.plainText, .json, .jpeg]
        let header = HTTPField.accept(types)
        #expect(header?.name == .accept)
        #expect(header?.value == types.compactMap(\.preferredMIMEType).joined(separator: ", "))
    }
    #endif
    
    @Test func `Content type header with string value`() async throws {
        let value = "some/mediatype"
        let header = HTTPField.contentType(value)
        #expect(header.name == .contentType)
        #expect(header.value == value)
    }
    
    @Test(arguments: mediaTypes)
    func `Content type header with media type`(mediaType: HTTPField.MediaType) async throws {
        let header = HTTPField.contentType(mediaType)
        #expect(header.name == .contentType)
        #expect(header.value == mediaType.description)
    }
    
    @Test func `Content type header with multiple media types`() async throws {
        let types: [HTTPField.MediaType] = [.applicationJSON, .textPlain, .imagePNG]
        let header = HTTPField.contentType(types)
        #expect(header.name == .contentType)
    }
    
    #if canImport(UniformTypeIdentifiers)
    @Test func `Content type header with uniform type identifier`() async throws {
        let type = UTType.json
        let header = HTTPField.contentType(type)
        #expect(header?.name == .contentType)
        #expect(header?.value == type.preferredMIMEType)
    }
    
    @Test func `Content type header with uniform type identifiers`() async throws {
        let types: [UTType] = [.plainText, .json, .jpeg]
        let header = HTTPField.contentType(types)
        #expect(header?.name == .contentType)
        #expect(header?.value == types.compactMap(\.preferredMIMEType).joined(separator: ", "))
    }
    #endif

    //MARK: - Accept Language
    @Test func `Accept language header from string value`() async throws {
        let value = "en-US,en;q=0.9"
        let header = HTTPField.acceptLanguage(value)
        #expect(header.name == .acceptLanguage)
        #expect(header.value == value)
    }
    
    @Test func `Accept language header from language`() async throws {
        let language = Locale.Language(languageCode: .chinese, script: .hanSimplified)
        let header = HTTPField.acceptLanguage(language)
        #expect(header.name == .acceptLanguage)
        #expect(header.value == language.maximalIdentifier)
    }
    
    @Test func `Accept language header from multiple languages`() async throws {
        let languages: [Locale.Language] = [
            Locale.Language(languageCode: .english),
            Locale.Language(languageCode: .navajo),
            Locale.Language(languageCode: .spanish, region: .latinAmerica),
            Locale.Language(languageCode: .mongolian)
        ]
        let header = HTTPField.acceptLanguage(languages)
        #expect(header.name == .acceptLanguage)
        #expect(header.value == languages.map(\.maximalIdentifier).joined(separator: ", "))
    }
}
