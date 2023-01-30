//
//  HeaderTypeTests.swift
//  
//
//  Created by Thomas De Leon on 1/25/23.
//

import XCTest
@testable import Relax

final class HeaderTypeTests: XCTestCase {
    
    func verify(_ header: Header, name: Header.Name, value: String) {
        XCTAssertEqual(header.name, name.rawValue)
        XCTAssertEqual(header.value, value)
        XCTAssertEqual(header.description, "\(name.rawValue):\(value)")
    }
    
    func testAccept() {
        let type = Header.ContentType.applicationJSON
        verify(.accept(type.rawValue), name: .accept, value: type.rawValue)
        verify(.accept(type), name: .accept, value: type.rawValue)
        let text = Header.ContentType.textPlain
        verify(.accept(text), name: .accept, value: text.rawValue)
    }
    
    func testAcceptLanguage() {
        let value = "en"
        verify(.acceptLanguage(value), name: .acceptLanguage, value: value)
    }
    
    func testAuthorization() {
        let value = "abcd"
        verify(.authorization(.basic, value: value), name: .authorization, value: "Basic \(value)")
        verify(.authorization(.bearer, value: value), name: .authorization, value: "Bearer \(value)")
        verify(.authorization(.digest, value: value), name: .authorization, value: "Digest \(value)")
        verify(.authorization("some"), name: .authorization, value: "some")
    }
    
    func testCacheControl() {
        let value = "no-cache"
        verify(.cacheControl(value), name: .cacheControl, value: value)
    }

    func testContentType() {
        let value = "some"
        verify(.contentType(value), name: .contentType, value: value)
        verify(.contentType(.textPlain), name: .contentType, value: Header.ContentType.textPlain.rawValue)
    }

}
