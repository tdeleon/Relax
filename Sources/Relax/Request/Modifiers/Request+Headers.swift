//
//  Request+Headers.swift
//  Relax
//
//  Created by Thomas De Leon on 1/24/23.
//

import Foundation
import HTTPTypes

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
