//
//  01-creating-app-02-16.swift
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
        
        static func getPhotos(rover: Rovers.Name, date: Date = .now) async throws -> Response {
            try await Request(.get, parent: Self.self) {
                PathComponents {
                    rover.rawValue
                    "photos"
                }
                QueryItems {
                    ("earth_date", dateFormatter.string(from: date))
                }
            }
            .send()
        }
    }
}
