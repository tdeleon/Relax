//
//  Tag.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
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
