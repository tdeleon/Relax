#if !os(watchOS)
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(Combine)
import Combine
#endif
@testable import Relax

struct ExampleService: Service {
    var baseURL: URL = URL(string: "https://www.example.com/")!
        
    struct Products {
        static let apiKey: String = "123"
        
        struct Put: ServiceRequest {
            let requestType: HTTPRequestMethod = .put
        }
        
        struct Get: ServiceRequest {
            let requestType: HTTPRequestMethod = .get
            var token: String
            var headers: [String : String] {
                return ["Authorization": "Basic \(token)",
                    "api-key": Products.apiKey]
            }
        }
    }
}

struct Examples: Service {
    let baseURL: URL = URL(string: "https://example.com/api/")!
    
    struct Customers {
        static let basePath = "customers"
        
        // Get customer by customer ID
        struct Get: ServiceRequest {
            let requestType: HTTPRequestMethod = .get
            
            var customerID: String
            var pathComponents: [String] {
                return [Customers.basePath, customerID]
            }
        }
        
        // Add new customer with customer ID, name
        struct Add: ServiceRequest {
            let requestType: HTTPRequestMethod = .post
            
            var customerID: String
            var name: String
            
            let pathComponents: [String] = [Customers.basePath]
            
            var body: Data? {
                let dictionary = ["id": customerID, "name": name]
                return try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            }
        }
    }
}

struct MyService: Service {
    let baseURL = URL(string: "https://example.com/")!
    
    // Products endpoint
    struct Products {
        static let name = "products"
        
        // Get request
        struct Get: ServiceRequest {
            let requestType: HTTPRequestMethod = .get
            let endpoint: Products? = Products()
            let productID: String
            
            var pathComponents: [String] {
                return [Products.name, productID]
            }
        }
    }
}

final class Example: XCTestCase {
    func testEndpoint() {
        let expectation = self.expectation(description: "Expect")
        
        Examples().request(Examples.Customers.Add(customerID: "123", name: "First Last")) { response in
            debugPrint(response)
            switch response {
            case .failure(let error):
                debugPrint(error)
            case .success(_):
                break
            }
            expectation.fulfill()
        }
        
//        Examples().request(Examples.Customers.Get(customerID: "123")) { response in
//            debugPrint(response)
//            switch response {
//            case .failure(let error):
//                debugPrint(error)
//            case .success(_):
//                break
//            }
//            expectation.fulfill()
//        }
        
//        MyService().request(MyService.Products.Get(productID: "1234")) { response in
//            debugPrint(response)
//            expectation.fulfill()
//        }
        waitForExpectations(timeout: 5)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class RelaxTests: XCTestCase {
    var cancellable: AnyCancellable?
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(Relax().text, "Hello, World!")
            let expectation = self.expectation(description: "expect")
        let service = ExampleService()
        let token = "1234"
        cancellable = service.request(ExampleService.Products.Get(token: token))
            .sink(receiveCompletion: { (completion) in
                defer {
                expectation.fulfill()
                }
                switch completion {
                case .failure(let error):
                    debugPrint(error)
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { (response) in
                debugPrint(response)
            })
            waitForExpectations(timeout: 31)
            
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
#endif

