#if !os(watchOS)
import XCTest
@testable import Relax

struct ExampleService: RelaxService {
    var baseURL: URL = URL(string: "https://www.example.com/")!
    
    static var session: URLSession = URLSession.shared
    
    struct Products: RelaxEndpoint {
        var service: RelaxService = ExampleService()
        
        var token: String?
        
        struct Get: RelaxRequest {
            let requestType: RelaxHTTPRequestType = .get
            
            let endpoint: RelaxEndpoint = Products()
            
            let token: String
            
            var headers: [String : String] {
                return ["Authorization": "Basic \(token)"]
            }
        }
        
    }
}

final class RelaxTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(Relax().text, "Hello, World!")
        let service = ExampleService(baseURL: URL(string: "http://www.com")!)
        
        service.make(<#T##request: RelaxRequest##RelaxRequest#>, completion: <#T##(Result<(request: RelaxRequest, response: HTTPURLResponse, data: Data?), RelaxRequestError>) -> ()#>)
        ExampleService().make(ExampleService.Products.Get(token: <#String#>))
        ExampleService().make(ExampleService.Products.Get()) { (result) in
            
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
#endif

