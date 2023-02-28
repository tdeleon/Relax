//
//  01-creating-app-02-15.swift
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
        static let path: String = "rovers"
        
        enum Name: String, CaseIterable {
            case curiosity
            case opportunity
            case spirit
        }
        
        struct Response: Codable {
            let photos: [Photos]
            
            struct Photos: Codable {
                let id: Int
                let imgSrc: URL
                let earthDate: Date
            }
        }
        
        private static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-M-d"
            return formatter
        }()
        
        @RequestBuilder<Rovers>
        private static func photosRequest(rover: Rovers.Name, date: Date) -> Request {
            Request.HTTPMethod.get
            PathComponents {
                rover.rawValue
                "photos"
            }
            QueryItems {
                ("earth_date", dateFormatter.string(from: date))
            }
        }
        
        static func getPhotos(rover: Rovers.Name, date: Date) async throws -> Response {
            try await photosRequest(rover: rover, date: date).send()
        }
    }
}
