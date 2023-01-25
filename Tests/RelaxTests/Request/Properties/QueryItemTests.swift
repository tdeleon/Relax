//
//  QueryItemTests.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import XCTest
@testable import Relax

final class QueryItemTests: XCTestCase {
    
    let item1 = URLQueryItem(name: "key1", value: "value1")
    let item2 = URLQueryItem(name: "key2", value: "value2")
    let item3 = URLQueryItem(name: "key2", value: "value3")

    func testInit() throws {
        let query = QueryItem(item1.name, item1.value)
        XCTAssertEqual(query.urlQueryItem, item1)
        
        let query2 = QueryItem(item2)
        XCTAssertEqual(query2.urlQueryItem, item2)
        
        let items = [item1, item2, item3]
        let queryItems = QueryItems(value: items)
        XCTAssertEqual(queryItems.baseValue, items)
        
        let queryItems2 = QueryItems(value: [query.urlQueryItem, query2.urlQueryItem])
        XCTAssertEqual(queryItems2.baseValue, [query.urlQueryItem, query2.urlQueryItem])
        
    }
    
    func testAppend() throws {
        let query = QueryItems(value: [item1])
        let other = QueryItems(value: [item2])

        XCTAssertEqual((query + other), QueryItems(value: [item1, item2]))
    }
    
    func testName() throws {
        let name = QueryItem.Name("name")
        let value = "value"
        let item = QueryItem(name, value)
        XCTAssertEqual(item.urlQueryItem, URLQueryItem(name: name.rawValue, value: value))
    }
    
    func testBuildEmpty() {
        let query = QueryItems {}
        XCTAssertTrue(query.baseValue.isEmpty)
    }
    
    func testBuilder() {
        let query = QueryItems(value: [item2])
        let items = QueryItems {
            QueryItem(item1)
            query
            item3
        }
        XCTAssertEqual(items.baseValue, [item1, item2, item3])
    }
    
    func testBuildOptional() {
        @QueryItems.Builder
        func query(_ include: Bool) -> QueryItems {
            if include {
                item1
            }
        }
        
        XCTAssertEqual(query(true).baseValue, [item1])
        XCTAssertTrue(query(false).baseValue.isEmpty)
    }
    
    func testBuildEither() {
        @QueryItems.Builder
        func query(_ include: Bool) -> QueryItems {
            if include {
                QueryItem(item1)
            }
            else {
                QueryItem(item2)
            }
        }
        
        XCTAssertEqual(query(true).baseValue, [item1])
        XCTAssertEqual(query(false).baseValue, [item2])
    }
    
    func testBuildArray() {
        let items = [item1, item2]
        let query = QueryItems {
            for queryItem in items {
                QueryItem(queryItem)
            }
        }
        XCTAssertEqual(query.baseValue, items)
    }
    
    func testBuildURLQueryItem() {
        let item = URLQueryItem(name: "name", value: "value")
        let query = QueryItems {
            item
        }
        XCTAssertEqual(query.baseValue, [item])
    }
    
    func testBuildLimitedAvailability() {
        let items = QueryItems {
            if #available(*) {
                item1
            }
        }
        XCTAssertEqual(items, QueryItems(value: [item1]))
    }
}
