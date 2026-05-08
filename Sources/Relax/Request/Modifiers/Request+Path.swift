//
//  Request+Path.swift
//  Relax
//
//  Created by Thomas De Leon on 5/8/26.
//

import Foundation
import HTTPTypes

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
