//
//  Tag.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation

/// Defines a Tag used to group Operations
///
/// Tags are arbitrary metadata with a name and optional description. When applied to a ``Endpoint/Operation``, the generated functions will be grouped under
/// an enum matching the tag name. This overrides the default behavior of grouping by the ``Endpoint``. The enum name is derived from the tag’s name
/// (sanitized and camel-cased).
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

extension Tag {
    /// A result builder to define Tags
    ///
    /// Use this result builder to define tags either with explicit tag definitions (with an optional summary), or as simple strings.
    /// ```swift
    /// var tags: [Tag] {
    ///     Tag("Accounts", summary: "User account operations")
    ///     "Billing" // Will define a tag as Tag("Billing")
    /// }
    /// ```
    ///
    /// - Note:This builder is used by the macro at compile time. Optionals, conditionals, and arrays are not supported to ensure deterministic macro expansion.
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> [Tag] {
            []
        }
        
        public static func buildPartialBlock(first: [Tag]) -> [Tag] {
            first
        }
        
        public static func buildPartialBlock(accumulated: [Tag], next: [Tag]) -> [Tag] {
            accumulated + next
        }
        
        public static func buildExpression(_ expression: Tag) -> [Tag] {
            [expression]
        }
        
        public static func buildExpression(_ expression: StaticString) -> [Tag] {
            [Tag("\(expression)")]
        }
        
        @available(*, unavailable, message: "Optionals are not supported in this builder.")
        public static func buildOptional(_ component: [Tag]?) -> [Tag] {
            component ?? []
        }
        
        @available(*, unavailable, message: "Conditionals are not supported in this builder.")
        public static func buildEither(first component: [Tag]) -> [Tag] {
            component
        }
        
        @available(*, unavailable, message: "Conditionals are not supported in this builder.")
        public static func buildEither(second component: [Tag]) -> [Tag] {
            component
        }
        
        @available(*, unavailable, message: "Arrays are not supported in this builder.")
        public static func buildArray(_ components: [[Tag]]) -> [Tag] {
            components.flatMap { $0 }
        }
        
        @available(*, unavailable, message: "Conditionals are not supported in this builder.")
        public static func buildLimitedAvailability(_ component: [Tag]) -> [Tag] {
            component
        }
    }
}
