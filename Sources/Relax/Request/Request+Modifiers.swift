//
//  Request+Modifiers.swift
//  
//
//  Created by Thomas De Leon on 1/24/23.
//

import Foundation

extension Request {
    /// Set the given property on this request.
    ///
    /// This will replace all the existing values of the same property type with the one provided.
    /// - Parameter property: The property to set.
    /// - Returns: A request with the property set.
    public func setting(_ property: some RequestProperty) -> Request {
        var request = self
        request._properties = request._properties.setting(property)
        return request
    }
    
    /// Adds the given property to this request.
    /// - Parameter property: The property to add.
    /// - Returns: A request with the property added to the existing property of the same type.
    public func adding(_ property: some RequestProperty) -> Request {
        var request = self
        request._properties = request._properties.adding(property)
        return request
    }
    
    /// Sets the configuration for this request.
    /// - Parameter configuration: The configuration to set.
    /// - Returns: A request with the provided configuration set.
    public func setting(_ configuration: Configuration) -> Request {
        var request = self
        request.configuration = configuration
        return request
    }
}

//MARK: Header modifiers
extension Request {
    /// Sets a header on this request
    /// - Parameters:
    ///   - name: The header name
    ///   - value: The header value. If this value is `nil`, the header will be removed from the request.
    /// - Returns: A request with the given header set.
    public func settingHeader(name: String, value: String?) -> Request {
        var request = self
        request.headers[name] = value
        return request
    }
    
    /// Sets a header on this request
    /// - Parameters:
    ///   - name: The header name
    ///   - value: The header value. If this value is `nil`, the header will be removed from the request.
    /// - Returns: A request with the given header set.
    public func settingHeader(name: Header.Name, value: String?) -> Request {
        settingHeader(name: name.rawValue, value: value)
    }
    
    /// Sets a header on this request
    /// - Parameter header: The header to set
    /// - Returns: A request with the given header set.
    public func settingHeader(_ header: Header) -> Request {
        settingHeader(name: header.name, value: header.value)
    }
    
    /// Adds a header on this request.
    ///
    /// If a header with the same name already exists, the value provided here will be appended to the existing value with a `,` character inserted between.
    /// - Parameter header: The header to add.
    /// - Returns: A request with the given header added.
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
    public func addingHeader(name: String, value: String) -> Request {
        var request = self
        request.headers = request.headers.mergingCommaSeparatedValues([name: value])
        return request
    }
    
    /// Adds a header on this request.
    ///
    /// If a header with the same name already exists, the value provided here will be appended to the existing value with a `,` character inserted between.
    /// - Parameters:
    ///   - name: The header name.
    ///   - value: The header value.
    /// - Returns: A request with the given header added.
    public func addingHeader(name: Header.Name, value: String) -> Request {
        addingHeader(name: name.rawValue, value: value)
    }
    
    /// Removes a header from this request.
    /// - Parameter name: The header name to remove.
    /// - Returns: A request with the given header removed.
    public func removingHeader(_ name: String) -> Request {
        settingHeader(name: name, value: nil)
    }
    
    /// Removes a header from this request
    /// - Parameter name: The header name to remove.
    /// - Returns: A request with the given header removed.
    public func removingHeader(_ name: Header.Name) -> Request {
        removingHeader(name.rawValue)
    }
}
