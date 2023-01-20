//
//  Body.swift
//  
//
//  Created by Thomas De Leon on 1/11/23.
//

import Foundation

public struct Body: RequestProperty {
    public var baseValue: Data?
    public let requestKeyPath = \Request.body
            
    public init(value: Data?) {
        self.baseValue = value
    }
    
    public init<Model: Encodable>(_ model: Model, encoder: JSONEncoder = JSONEncoder()) {
        self.init(value: try? encoder.encode(model))
    }
    
    public func append(to property: inout Data?) {
        guard let baseValue else { return }
        property?.append(baseValue)
    }
}
