import XCTest
import BufferLayoutSwift

// MARK: - Structs
private struct UIntTest: BufferLayout {
    // parsable
    var uint8: UInt8
    var uint16: UInt16
    var uint32: UInt32
    var uint64: UInt64
    var int32: Int32
    
    // non-parsable part
    var optionalString: String?
    var string: String
    var exGetter: Int {0}
    func exFunc() {}
}

private struct UnsupportedIntTest: BufferLayout {
    var uint8: UInt8
    var uint16: UInt16
    var uint32: UInt32
    var uint64: UInt64
    var int: Int
}

// MARK: - Tests
class DecodingBufferLayoutTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDecodingFailed() throws {
        // not enough bytes
        XCTAssertThrowsError(try UIntTest(buffer: Data([1,3,0,3,1,0,0,1,3,0,3,1,0,0])))
        
        // property not supported
        XCTAssertThrowsError(try UnsupportedIntTest(buffer: Data([1,3,0,3,1,0,0,1,3,0,3,1,0,0,0,1,3,0,3,1,0,0])))
    }
    
    func testDecodingBuildInSupportedTypes() throws {
        let test = try UIntTest(buffer: Data([1,3,0,3,1,0,0,1,3,0,3,1,0,0,1,1,0,0,1]))
        XCTAssertEqual(test.uint8, 1)
        XCTAssertEqual(test.uint16, 3)
        XCTAssertEqual(test.uint32, 259)
        XCTAssertEqual(test.uint64, 72057598383227649)
        XCTAssertEqual(test.uint32, 259)
    }
}
