//
//  DescriptionBuilder.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation

@resultBuilder
public enum DescriptionBuilder {
    public static func buildBlock() -> String? {
        nil
    }
    
    public static func buildPartialBlock(first: String?) -> String? {
        first
    }
    
    public static func buildPartialBlock(accumulated: String?, next: String?) -> String? {
        guard let accumulated, let next else { return nil }
        return accumulated.appending("\n\(next)")
    }
    
    public static func buildExpression(_ expression: StaticString) -> String? {
        "\(expression)"
    }
}
