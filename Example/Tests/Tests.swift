import XCTest
import BufferLayoutSwift

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() throws {
        let test = try Test(data: Data([1,2]))
        XCTAssertEqual(test.x, 1)
        XCTAssertEqual(test.y, 2)
    }
}

struct Test: BufferLayout {
    var x: UInt8
    var y: UInt8
}
