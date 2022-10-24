//
//  QueryItem.swift
//  
//
//  Created by Thomas De Leon on 7/17/22.
//

import Foundation

public protocol QueryItemProviding {
    var queryItem: URLQueryItem? { get }
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

@propertyWrapper struct QueryItem<Value>: QueryItemProviding {
    let key: String
    var wrappedValue: Value {
        get {
            guard let value = value else {
                fatalError("Cannot access before being initialized")
            }
            return value
        }
        set {
            value = newValue
            guard let lossless = newValue as? LosslessStringConvertible else {
                if let optional = newValue as? AnyOptional, optional.isNil, allowEmptyValue {
                    queryItem = allowEmptyValue ? URLQueryItem(name: key, value: nil) : nil
                } else {
                    queryItem = nil
                }
                return
            }
            queryItem = URLQueryItem(name: key, value: String(lossless.description))
        }
    }
    
    private var value: Value?
    private var allowEmptyValue: Bool
    
    private(set) var queryItem: URLQueryItem?
    
    init(_ key: String, allowEmptyValue: Bool = false) {
        self.key = key
        self.allowEmptyValue = allowEmptyValue
    }
    
    init(wrappedValue: Value, _ key: String, allowEmptyValue: Bool = false) {
        self.key = key
        self.allowEmptyValue = allowEmptyValue
        self.wrappedValue = wrappedValue
    }
}
