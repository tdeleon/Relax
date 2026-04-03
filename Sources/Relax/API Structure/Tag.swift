//
//  Tag.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation

/// Used to group Operations
///
/// Tags are arbitrary metadata with a name and optional description. When applied to a ``Path/Operation``, the generated functions will be grouped under
/// an enum matching the tag name. This overrides the default behavior of grouping by the ``Path``.
public struct Tag: Hashable, Sendable {
    /// The name of the tag
    public let name: String
    /// A short summary of the tag
    public let summary: String?
    /// A longer description of the tag
    public let description: String?
    
    /// Creates a new tag
    /// - Parameters:
    ///   - name: The name of the tag
    ///   - summary: A short summary describing the tag
    ///   - description: A longer description of the tag
    public init(
        _ name: String,
        summary: String? = nil,
        @DescriptionBuilder description: () -> String? = { nil }
    ) {
        self.name = name
        self.summary = summary
        self.description = description()
    }
}
