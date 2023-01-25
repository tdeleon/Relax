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
    
    struct Test: Codable, Hashable {
        let name: String
    }
    
    let model = Test(name: "abc")
    
    func testInit() {
        let body = Body(value: stringData1)
        
        XCTAssertEqual(body.baseValue, stringData1)
    }
    
    func testInitModel() throws {
        let encoder = JSONEncoder()
        
        let body = Body(model, encoder: encoder)
        let bodyData = try XCTUnwrap(body.baseValue)
        XCTAssertEqual(try? JSONDecoder().decode(Test.self, from: bodyData), model)
    }
    
    func testAppend() throws {
        let body1 = Body { stringData1 }
        let body2 = Body { stringData2 }
        
        XCTAssertEqual(body1 + body2, Body(value: stringData1! + stringData2!))
        
        let bodyNil = Body {}
        
        XCTAssertEqual(body1 + bodyNil, Body(value: stringData1!))
        XCTAssertEqual(bodyNil + body2, Body(value: stringData2!))
        XCTAssertEqual(bodyNil + bodyNil, Body(value: nil))
    }
    
    func testBuildEmpty() {
        XCTAssertEqual(Body {}, Body(value: nil))
    }
    
    func testBuild() {
        let body1 = Body(value: stringData1)
        
        XCTAssertEqual(Body { body1 }, body1)
    }
    
    func testBuildOptional() {
        @Body.Builder
        func body(include: Bool) -> Body {
            if include {
                stringData1
            }
        }
        XCTAssertEqual(body(include: true), Body(value: stringData1))
        XCTAssertEqual(body(include: false), Body(value: nil))
    }
    
    func testBuildEither() {
        @Body.Builder
        func body(include: Bool) -> Body {
            if include {
                stringData1
            } else {
                stringData2
            }
        }
        
        XCTAssertEqual(body(include: true), Body(value: stringData1))
        XCTAssertEqual(body(include: false), Body(value: stringData2))
    }
    
    func testBuildArray() {
        let data = [stringData1, stringData2]
        
        @Body.Builder
        var body: Body {
            for item in data {
                item
            }
        }
        XCTAssertEqual(body, Body(value: data.compactMap { $0 }.reduce(Data(), +)))
    }
    
    func testBuildCodable() throws {
        @Body.Builder
        var body: Body {
            model
        }
        XCTAssertEqual(body, Body(model))
    }
}
