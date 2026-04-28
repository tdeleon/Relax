//
//  String+Extension.swift
//  Relax
//
//  Created by Thomas De Leon on 4/23/26.
//

import Foundation

extension String {
    internal func camelCased() -> String {
        let components = components(separatedBy: CharacterSet.alphanumerics.inverted)
        let first = components.first?.lowercased() ?? ""
        let remaining = components.dropFirst().map(\.capitalized)
        
        return ([first] + remaining).joined()
    }
}
