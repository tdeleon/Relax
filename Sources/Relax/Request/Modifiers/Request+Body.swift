//
//  Request+Body.swift
//  Relax
//
//  Created by Thomas De Leon on 5/8/26.
//

import Foundation
import HTTPTypes

extension Request {
    /// Set the body of the request with data
    /// - Parameter data: The data to set as the body
    /// - Returns: A request with the specified data as the body
    public func settingBody(data: Data?) -> Request {
        var request = self
        request.body = data
        return request
    }
    
    /// Set the body of the request
    /// - Parameter body: The body to set
    /// - Returns: A request with the specified Body set
    public func settingBody(_ body: Body) -> Request {
        settingBody(data: body._value)
    }
    
    /// Set the body of the request with a builder
    /// - Parameter body: The body to set
    /// - Returns: A request with the specified Body set from a builder
    public func settingBody(@Body.Builder body: () -> Body) -> Request {
        settingBody(body())
    }
}
