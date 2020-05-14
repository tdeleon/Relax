//
//  RelaxEndpoint.swift
//  
//
//  Created by Thomas De Leon on 5/12/20.
//

import Foundation

/// <#Description#>
public protocol RelaxEndpoint {
    ///
    var service: RelaxService { get }
    ///
    var name: String? { get }
}

public extension RelaxEndpoint {
    var name: String? {
        return nil
    }
}

extension RelaxEndpoint where Self : Hashable {}
