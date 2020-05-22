//
//  File.swift
//  
//
//  Created by Thomas De Leon on 5/21/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import MockURLSession
@testable import Relax

extension MockURLSession {
    
    convenience init(requestError: RequestError) {
        switch requestError {
        case .badRequest(_):
            self.init(httpStatus: 400)
        case .noResponse(_):
            self.init(response: nil)
        case .notFound(_):
            self.init(httpStatus: 404)
        case .other(_, let message):
            self.init(error: NSError(domain: "com.relax.test", code: -1, userInfo: [NSLocalizedDescriptionKey: message]))
        case .otherHTTP(_, let status):
            self.init(httpStatus: status)
        case .serverError(_, let status):
            self.init(httpStatus: status)
        case .unauthorized(_):
            self.init(httpStatus: 401)
        case .urlError(_, let error):
            self.init(error: error)
        }
    }
}
