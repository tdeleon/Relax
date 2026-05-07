//
//  Request+Modifiers.swift
//  
//
//  Created by Thomas De Leon on 1/24/23.
//

import Foundation
import HTTPTypes

//MARK: Header modifiers
extension Request {
    /// Sets a header on this request with the specified name and value.
    /// - Parameters:
    ///   - name: The header name to set
    ///   - value: The value to set
    /// - Returns: A request with the given header set or removed.
    ///
    /// If a header with the name is already present, it's value will be replaced by the `value` provided. If `value` is `nil`, the header will be removed.
    public func settingHeader(name: String, value: String?) -> Request {
        guard let name = HTTPField.Name(name) else { return self }
        return settingHeader(name: name, value: value)
    }
    
    /// Sets a header on this request with the specified name and value.
    /// - Parameters:
    ///   - name: The header name to set
    ///   - value: The value to set
    /// - Returns: A request with the given header set or removed.
    ///
    /// If a header with the name is already present, it's value will be replaced by the `value` provided. If `value` is `nil`, the header will be removed.
    public func settingHeader(name: HTTPField.Name, value: String?) -> Request {
        var request = self
        request.headers[name] = value
        return request
    }
    
    /// Sets a header value on this request
    /// - Parameter header: The header to set
    /// - Returns: A request with the given header set.
    ///
    /// If the header already exists, its value will be replaced with the one provided.
    public func settingHeader(_ header: HTTPField) -> Request {
        var request = self
        request.headers[header.name] = header.value
        return request
    }
    
    /// Adds a header to this request.
    ///
    /// - Parameter header: The header to add.
    /// - Returns: A request with the given header added.
    ///
    /// - Note: If the same header name is already present, an additional one will be added.
    public func addingHeader(_ header: HTTPField) -> Request {
        var request = self
        request.headers.append(header)
        return request
    }
    
    /// Adds a header to this request with the specified name and value.
    ///
    /// - Parameters:
    ///   - name: The header name.
    ///   - value: The header value.
    /// - Returns: A request with the given header added.
    /// - Note: If the same header name is already present, an additional one will be appended.
    public func addingHeader(name: HTTPField.Name, value: String) -> Request {
        addingHeader(HTTPField(name: name, value: value))
    }
    
    /// Adds a header to this request with the specified name and value.
    ///
    /// - Parameters:
    ///   - name: The header name.
    ///   - value: The header value.
    /// - Returns: A request with the given header added.
    ///
    /// - Note: If the same header name is already present, an additional one will be appended.
    public func addingHeader(name: String, value: String) -> Request {
        guard let name = HTTPField.Name(name) else { return self }
        return addingHeader(HTTPField(name: name, value: value))
    }
    
    /// Removes a header from this request.
    /// - Parameter name: The header name to remove.
    /// - Returns: A request with the given header removed.
    public func removingHeader(_ name: String) -> Request {
        settingHeader(name: name, value: nil)
    }
    
    /// Removes a header from this request.
    /// - Parameter name: The header name to remove.
    /// - Returns: A request with the given header removed.
    public func removingHeader(_ name: HTTPField.Name) -> Request {
        settingHeader(name: name, value: nil)
    }
    
    // Deprecated
    
    /// Sets a header on this request
    /// - Parameters:
    ///   - name: The header name
    ///   - value: The header value. If this value is `nil`, the header will be removed from the request.
    /// - Returns: A request with the given header set.
    @available(*, deprecated, message: "Use HTTPField.Name instead.")
    public func settingHeader(name: Header.Name, value: String?) -> Request {
        settingHeader(name: name.rawValue, value: value)
    }
    
    /// Sets a header on this request
    /// - Parameter header: The header to set
    /// - Returns: A request with the given header set.
    @available(*, deprecated, message: "Use HTTPField.Name instead.")
    public func settingHeader(_ header: Header) -> Request {
        settingHeader(name: header.name, value: header.value)
    }
    
    /// Adds a header on this request.
    ///
    /// If a header with the same name already exists, the value provided here will be appended to the existing value with a `,` character inserted between.
    /// - Parameter header: The header to add.
    /// - Returns: A request with the given header added.
    @available(*, deprecated, message: "Use HTTPField.Name instead.")
    public func addingHeader(_ header: Header) -> Request {
        addingHeader(name: header.name, value: header.value)
    }
    

    
    /// Adds a header on this request.
    ///
    /// If a header with the same name already exists, the value provided here will be appended to the existing value with a `,` character inserted between.
    /// - Parameters:
    ///   - name: The header name.
    ///   - value: The header value.
    /// - Returns: A request with the given header added.
    @available(*, deprecated, message: "Use HTTPField.Name instead.")
    public func addingHeader(name: Header.Name, value: String) -> Request {
        addingHeader(name: name.rawValue, value: value)
    }
    

    
    /// Removes a header from this request
    /// - Parameter name: The header name to remove.
    /// - Returns: A request with the given header removed.
    @available(*, deprecated, message: "Use HTTPField.Name instead.")
    public func removingHeader(_ name: Header.Name) -> Request {
        removingHeader(name.rawValue)
    }
}

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
        var request = removingQueryItems(named: named)
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

extension Request {
    /// Appends a path component to the existing path of a request
    /// - Parameter component: The path component to append
    /// - Returns: A request with the component appended.
    public func appendingPathComponent(_ component: String) -> Request {
        var request = self
        request.pathComponents += PathComponents(component)
        return request
    }
    
    /// Sets the path of a request
    /// - Parameter path: The path to set
    /// - Returns: A request with the specified path set as its path, replacing any existing path.
    public func settingPath(_ path: String) -> Request {
        var request = self
        request.pathComponents = PathComponents(path)
        return request
    }
}
