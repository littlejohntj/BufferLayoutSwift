import XCTest
import BufferLayoutSwift
import Runtime

// MARK: - Structs
private struct UIntTest: BufferLayout {
    // parsable
    let uint8: UInt8
    let uint16: UInt16 // excluded -> default to 0
    let uint32: UInt32?
    let uint64: UInt64
    let int32: Int32
    let bool: Bool
    
    // non-parsable part
    var optionalString: String?
    let string: String
    var exGetter: Int {0}
    func exFunc() {}
    
    static func injectOtherProperties(typeInfo: TypeInfo, currentInstance: inout UIntTest) throws {
        let stringProp = try typeInfo.property(named: "string")
        try stringProp.set(value: "test", on: &currentInstance)
    }
    
    static var excludedPropertyNames: [String] {["uint16"]}
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
    }
    
    func testDecodingBuildInSupportedTypes() throws {
        let test = try UIntTest(buffer: Data([1,3,1,0,0,1,3,0,3,1,0,0,1,1,0,0,1,0]))
        XCTAssertEqual(test.uint8, 1)
        XCTAssertEqual(test.uint16, 0) // excluded
        XCTAssertEqual(test.uint32, 259)
        XCTAssertEqual(test.uint64, 72057598383227649)
        XCTAssertEqual(test.uint32, 259)
        XCTAssertEqual(test.bool, false)
        XCTAssertEqual(test.string, "test")
    }
}
