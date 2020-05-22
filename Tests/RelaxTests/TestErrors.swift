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
@testable import Relax

extension RequestError {
    static let testErrors: [RequestError] = [RequestError.badRequest(request: ExampleService.Get.urlRequest),
                                             RequestError.unauthorized(request: ExampleService.Get.urlRequest),
                                             RequestError.notFound(request: ExampleService.Get.urlRequest),
                                             RequestError.serverError(request: ExampleService.Get.urlRequest, status: 500),
                                             RequestError.otherHTTP(request: ExampleService.Get.urlRequest, status: 999),
                                             RequestError.urlError(request: ExampleService.Get.urlRequest, error: URLError(.badURL)),
                                             RequestError.noResponse(request: ExampleService.Get.urlRequest),
                                             RequestError.other(request: ExampleService.Get.urlRequest, message: "Other error occurred")]
}
