//
//  01-creating-app-02-07.swift
//  
//
//  Created by Thomas De Leon on 2/28/23.
//

import Foundation
import Relax

enum MarsPhotos: Service {
    static let baseURL: URL = URL(string: "https://api.nasa.gov/mars-photos/api/v1")!
    
    static var sharedProperties: Request.Properties {
        QueryItems {
            ("api_key", "DEMO_KEY")
        }
    }
    
    enum Rovers: Endpoint {
        typealias Parent = MarsPhotos
    }
}
