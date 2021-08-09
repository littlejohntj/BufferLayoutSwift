import XCTest
import BufferLayoutSwift
import Runtime

// MARK: - Structs
extension UInt128: BufferLayoutProperty {
    
}
private struct UIntTest: BufferLayout {
    // parsable
    let vecu8: VecU8
    let uint128: UInt128
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
        let array: [UInt8] = [
            3,0,0,0,1,2,3, // vecu8
            4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // uint128
            1, // uint8
            3,0,0,0, // uint32
            1,3,0,3,1,0,0,1, // uint64?
            1,0,0,1,
            0 // bool
        ]
        let test = try UIntTest(buffer: Data(array))
        XCTAssertEqual(test.vecu8.length, 3)
        XCTAssertEqual(test.vecu8.bytes, [1,2,3])
        XCTAssertEqual(test.uint128, 4)
        XCTAssertEqual(test.uint8, 1)
        XCTAssertEqual(test.uint16, 0) // excluded
        XCTAssertEqual(test.uint32, 3)
        XCTAssertEqual(test.uint64, 72057598383227649)
        XCTAssertEqual(test.bool, false)
        XCTAssertEqual(test.string, "test")
        
        XCTAssertEqual([UInt8](try test.encode()), array)
    }
}
