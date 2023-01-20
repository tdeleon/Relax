//
//  BodyTests.swift
//  
//
//  Created by Thomas De Leon on 1/20/23.
//

import XCTest
@testable import Relax

final class BodyTests: XCTestCase {

    let stringData1 = "Test".data(using: .utf8)
    let stringData2 = "Test2".data(using: .utf8)
    
    func testInit() {
        let body = Body(value: stringData1)
        
        XCTAssertEqual(body.baseValue, stringData1)
    }
    
    func testInitModel() throws {
        struct Test: Codable, Hashable {
            let name: String
        }
        
        let model = Test(name: "abc")

        let encoder = JSONEncoder()
        
        let body = Body(model, encoder: encoder)
        let bodyData = try XCTUnwrap(body.baseValue)
        XCTAssertEqual(try? JSONDecoder().decode(Test.self, from: bodyData), model)
    }
    
    func testAppend() throws {
        var mutableData: Data? = stringData1
        let body = Body(value: stringData2)
        
        body.append(to: &mutableData)
        XCTAssertEqual(mutableData, stringData1! + stringData2!)
    }
}
