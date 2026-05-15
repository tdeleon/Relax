//
//  Request+QueryItems.swift
//  Relax
//
//  Created by Thomas De Leon on 5/8/26.
//

import Foundation
import HTTPTypes

extension Request {
    /// Adds the specified name and value as a query item to the request.
    /// - Parameters:
    ///   - name: The name of the query item
    ///   - value: The value of the query item
    /// - Returns: A request with the name and value added as a query item.
    public func addingQueryItem(name: String, value: String?) -> Request {
        addingQueryItem(URLQueryItem(name: name, value: value))
    }
    
    /// Add the specified query item to the request.
    /// - Parameter item: The item to add
    /// - Returns: A request with the query item added.
    public func addingQueryItem(_ item: URLQueryItem) -> Request {
        var request = self
        request.queryItems.append(item)
        return request
    }
    
    /// Replace query items matching the specified name with the value provided on the request.
    /// - Parameters:
    ///   - named: The name of the query item to replace
    ///   - value: The value to set
    /// - Returns: A request with the query item replaced with the new value.
    ///
    /// If there are multiple existing query items with the same name, then they will all be removed, and a single query item with the new value will be added. If
    /// there is no existing matching query item, then a new one will be added with the given name and value.
    public func replacingQueryItems(_ named: String, value: String?) -> Request {
        let request = removingQueryItems(named: named)
        return request.addingQueryItem(name: named, value: value)
    }
    
    /// Replace a query item with the one specified on the request.
    /// - Parameter item: The query to replace with
    /// - Returns: A request with the first matching query item name replaced with the new one provided.
    ///
    /// If there is an existing query item matching the name of the one provided, the first match will be replaced with the provided one. Any subsequent matches
    /// will not be modified. If there are no matching query items, the request is not modified.
    public func replacingQueryItem(_ item: URLQueryItem) -> Request {
        guard let found = queryItems.firstIndex(where: { $0 == item }) else { return self }
        var request = self
        request.queryItems[found] = item
        return request
    }
    
    /// Remove a query item from the request.
    /// - Parameter item: The query item to remove
    /// - Returns: A request with the query item removed.
    ///
    /// Removes the first matching query item where both name and value match. Subsequent matches are not removed.
    public func removingQueryItem(_ item: URLQueryItem) -> Request {
        guard let found = queryItems.firstIndex(where: { $0 == item }) else { return self }
        var request = self
        request.queryItems.remove(at: found)
        return self
    }
    
    /// Removes query items matching the specified name from the request.
    /// - Parameter name: The name of the query items to remove
    /// - Returns: A request with the query items with names matching the specified name removed.
    ///
    /// Removes all query items from the request with a name matching the one provided.
    public func removingQueryItems(named name: String) -> Request {
        var request = self
        queryItems.enumerated().forEach {
            if $0.element.name == name {
                request.queryItems.remove(at: $0.offset)
            }
        }
        return request
    }
}
