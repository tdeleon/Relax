//
//  Request+Modifiers.swift
//  
//
//  Created by Thomas De Leon on 1/24/23.
//

import Foundation

extension Request {
    /// <#Description#>
    /// - Parameter property: <#property description#>
    /// - Returns: <#description#>
    public func setting(_ property: some RequestProperty) -> Request {
        var request = self
        request._properties = request._properties.setting(property)
        return request
    }
    
    /// <#Description#>
    /// - Parameter property: <#property description#>
    /// - Returns: <#description#>
    public func adding(_ property: some RequestProperty) -> Request {
        var request = self
        request._properties = request._properties.adding(property)
        return request
    }
    
    /// <#Description#>
    /// - Parameter configuration: <#configuration description#>
    /// - Returns: <#description#>
    public func setting(_ configuration: Configuration) -> Request {
        var request = self
        request.configuration = configuration
        return request
    }
}

extension Request {
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - value: <#value description#>
    /// - Returns: <#description#>
    public func settingHeader(name: String, value: String?) -> Request {
        var request = self
        request.headers[name] = value
        return request
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - value: <#value description#>
    /// - Returns: <#description#>
    public func settingHeader(name: Header.Name, value: String?) -> Request {
        settingHeader(name: name.rawValue, value: value)
    }
    
    public func settingHeader(_ header: Header) -> Request {
        settingHeader(name: header.name, value: header.value)
    }
    
    /// <#Description#>
    /// - Parameter header: <#header description#>
    /// - Returns: <#description#>
    public func addingHeader(_ header: Header) -> Request {
        addingHeader(name: header.name, value: header.value)
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - value: <#value description#>
    /// - Returns: <#description#>
    public func addingHeader(name: String, value: String) -> Request {
        var request = self
        request.headers = request.headers.mergingCommaSeparatedValues([name: value])
        return request
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - value: <#value description#>
    /// - Returns: <#description#>
    public func addingHeader(name: Header.Name, value: String) -> Request {
        addingHeader(name: name.rawValue, value: value)
    }
    
    /// <#Description#>
    /// - Parameter name: <#name description#>
    /// - Returns: <#description#>
    public func removingHeader(_ name: String) -> Request {
        settingHeader(name: name, value: nil)
    }
    
    /// <#Description#>
    /// - Parameter name: <#name description#>
    /// - Returns: <#description#>
    public func removingHeader(_ name: Header.Name) -> Request {
        removingHeader(name.rawValue)
    }
}
