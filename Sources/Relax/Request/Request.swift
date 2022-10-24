//
//  Request.swift
//  
//
//  Created by Thomas De Leon on 7/18/22.
//

import Foundation

public protocol Request: URLSubPath {
    typealias Response = (request: URLRequest, response: HTTPURLResponse, data: Data)
    
    typealias RequestCompletion = (_ result: Result<Response, RequestError>) -> Void
    
    typealias RequestModelCompletion<ResponseModel: Decodable> = (_ result: Result<ResponseModel, RequestError>) -> Void
    
    var httpMethod: HTTPRequestMethod { get }
    
    var path: String { get }
    
    var pathPrefix: String { get }
    var pathSuffix: String { get }
    var queryParameters: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var contentType: RequestContentType? { get }
    var body: Data? { get }
    var timeout: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

public protocol RequestEncodable: Request {
    associatedtype RequestBodyType: Encodable
    var requestModel: RequestBodyType { get }
    var encoder: JSONEncoder { get }
}

extension RequestEncodable {
    public var encoder: JSONEncoder {
        JSONEncoder()
    }
    public var body: Data? {
        try? encoder.encode(requestModel)
    }
}

extension Mirror {
    static func childValues<C>(of subject: Any, matching: C.Type) -> [C] {
        return Mirror(reflecting: subject).children.map(\.value).compactMap { $0 as? C }
    }
}

public protocol Configurable {
    var timeout: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var checkHTTPStatus: Bool { get }
    
}

extension Request {
    public var timeout: TimeInterval { 60 }
    public var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    public var pathPrefix: String { "" }
    public var pathSuffix: String { "" }
    public var path: String { pathPrefix + pathParameters.joined(separator: "/") + pathSuffix }
    
    public var url: URL { Parent.url.appendingPathComponent(path) }
    public var queryParameters: [URLQueryItem] {
        Mirror.childValues(of: self, matching: QueryItemProviding.self).compactMap(\.queryItem)
    }
    public var headers: [String: String] { [:] }
    public var contentType: RequestContentType? { .applicationJSON }
    public var body: Data? { nil }
    
    public var pathParameters: [String] {
        Mirror.childValues(of: self, matching: PathComponent.self).map(\.wrappedValue)
    }
    
    public var urlRequest: URLRequest {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        queryParameters.forEach { components?.queryItems?.append($0) }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        
        if let contentType = contentType {
            request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        request.httpBody = body
        
        request.timeoutInterval = timeout
        request.cachePolicy = cachePolicy
        
        return request
    }
    
    @discardableResult
    public func send(
        session: URLSession = URLSession.shared,
        timeout: TimeInterval? = nil,
        autoResumeTask: Bool = true,
        completion: @escaping RequestCompletion
    ) -> URLSessionDataTask? {
        var request = urlRequest
        if let timeout = timeout {
            request.timeoutInterval = timeout
        }
        // Create the task
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil,
            let data = data else {
                // Check for URLErrors
                if let urlError = error as? URLError {
                    return completion(.failure(.urlError(request: request, error: urlError)))
                }
                // Any other error
                return completion(.failure(.other(request: request, message: error!.localizedDescription)))
            }
            
            // Check for an HTTPURLResponse
            guard let response = response,
                let httpResponse = response as? HTTPURLResponse else {
                    return completion(.failure(.urlError(request: request, error: URLError(.unknown))))
            }
            // Check for http status code errors (4xx-5xx series)
            if let httpError = RequestError(httpStatusCode: httpResponse.statusCode, request: request) {
                completion(.failure(httpError))
            }
            // Success
            else {
                completion(.success((request, httpResponse, data)))
            }
        }
        if autoResumeTask {
            task.resume()
        }
        return task
    }
    
    @discardableResult
    public func send<ResponseModel: Decodable>(
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession = URLSession.shared,
        timeout: TimeInterval? = nil,
        autoResumeTask: Bool = true,
        completion: @escaping RequestModelCompletion<ResponseModel>
    ) -> URLSessionDataTask? {
        send(
            session: session,
            timeout: timeout,
            autoResumeTask: autoResumeTask) { result in
                do {
                    let success = try result.get()
                    let decoded = try decoder.decode(ResponseModel.self, from: success.data)
                    completion(.success(decoded))
                } catch let error as DecodingError {
                    return completion(.failure(.decoding(request: urlRequest, error: error)))
                } catch let error as RequestError {
                    return completion(.failure(error))
                } catch {
                    return completion(.failure(.other(request: urlRequest, message: error.localizedDescription)))
                }
            }
    }
}

internal struct RequestGroup<Container: URLProviding>: Request {
    
    typealias Parent = Container
    
    let requests: [any Request]
    
    var httpMethod: HTTPRequestMethod {
        requests.map(\.httpMethod).first ?? .get
    }
    
    var headers: [String : String] {
        Dictionary(
            requests
                .map(\.headers)
                .flatMap { $0 },
            uniquingKeysWith: +
        )
    }
    
    var queryParameters: [URLQueryItem] {
        requests.flatMap(\.queryParameters)
    }
    
    var body: Data? {
        let allData = requests.map(\.body).compactMap { $0 }
        guard !allData.isEmpty else { return nil }
        return allData.reduce(Data(), +)
    }
    
    var timeout: TimeInterval {
        requests.map(\.timeout).first ?? 60
    }
    
    var cachePolicy: URLRequest.CachePolicy {
        requests.map(\.cachePolicy).first ?? .useProtocolCachePolicy
    }
}

struct QueryParameter<U: URLProviding>: Request {
    typealias Parent = U

    var httpMethod: HTTPRequestMethod
    
    
    var queryParameters: [URLQueryItem]
}

@resultBuilder
struct RequestBuilder<Container: URLProviding> {
    static func buildBlock(_ components: any Request...) -> any Request {
        RequestGroup<Container>(requests: components)
    }
}
