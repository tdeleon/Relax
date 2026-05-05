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
    
    internal func wrapped(lineLength: Int = 100) -> [String] {
        stride(from: 0, to: count, by: lineLength).map {
            let start = index(startIndex, offsetBy: $0)
            let end = index(start, offsetBy: lineLength, limitedBy: endIndex) ?? endIndex
            return String(self[start..<end])
        }
    }
    
    internal func commentFormatted(lineLength: Int = 100) -> String {
        guard !self.isEmpty else { return "" }
        return wrapped(lineLength: lineLength)
            .map { "/// \($0)" }
            .joined(separator: "\n")
    }
}
