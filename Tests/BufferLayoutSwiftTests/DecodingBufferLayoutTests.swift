import XCTest
import BufferLayoutSwift
import Runtime

// MARK: - Structs
extension UInt128: BufferLayoutProperty {
    
}
private struct VecU8: BufferLayoutProperty {
    let length: UInt32
    let bytes: [UInt8]
    
    init(buffer: Data, pointer: inout Int) throws {
        let length = try UInt32(buffer: buffer, pointer: &pointer)
        guard buffer.count >= 4 + Int(length) else {
            throw BufferLayoutSwift.Error.bytesLengthIsNotValid
        }
        self.length = length
        self.bytes = Array(buffer[pointer..<pointer+Int(length)])
        pointer += Int(length)
    }
    
    func serialize() throws -> Data {
        try length.serialize() +
        Data(bytes)
    }
}
private struct MyNumberCollection: BufferLayout {
    // parsable
    let vecu8: VecU8
    let uint128: UInt128
    let uint8: UInt8
    let uint16: UInt16 // excluded -> default to 0
    let nested: MyNestedNumberCollection
    let uint32: UInt32?
    let uint64: UInt64
    let int32: Int32
    let bool: Bool
    
    // non-parsable part
    var optionalString: String?
    let string: String
    var exGetter: Int {0}
    func exFunc() {}
    
    static func injectOtherProperties(typeInfo: TypeInfo, currentInstance: inout MyNumberCollection) throws {
        let stringProp = try typeInfo.property(named: "string")
        try stringProp.set(value: "test", on: &currentInstance)
    }
    
    static var excludedPropertyNames: [String] {["uint16"]}
}

private struct MyNestedNumberCollection: BufferLayout, Equatable {
    let uint8: UInt8
    let nested: MyNestedOfNestedNumberCollection
    let uint64: UInt64
}

private struct MyNestedOfNestedNumberCollection: BufferLayout, Equatable {
    let uint16: UInt16
    let uint32: UInt32
}

private struct UnsupportedIntTest: BufferLayout {
    var uint8: UInt8
    var uint16: UInt16
    var uint32: UInt32
    var uint64: UInt64
    var int: Int
}

// MARK: - Tests
class BufferLayoutTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDeserializingFailed() throws {
        // not enough bytes
        var pointer = 0
        XCTAssertThrowsError(try MyNumberCollection.init(
                                buffer: Data([1,3,0,3,1,0,0,1,3,0,3,1,0,0]),
                                pointer: &pointer))
    }
    
    func testSerializingAndDeserializing() throws {
        let array: [UInt8] = [
            3,0,0,0,1,2,3, // vecu8
            4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, // uint128
            1, // uint8
                1, // uint8 (nested)
                    0,0, // uint16 (nestedOfNested)
                    3,0,0,0, // uint32 (nestedOfNested)
                1,3,0,3,1,0,0,1, //uint64 (nested)
            3,0,0,0, // uint32
            1,3,0,3,1,0,0,1, // uint64?
            1,0,0,1,
            0 // bool
        ]
        var pointer = 0
        let test = try MyNumberCollection(buffer: Data(array), pointer: &pointer)
        XCTAssertEqual(test.vecu8.bytes, [1,2,3])
        XCTAssertEqual(test.uint128, 4)
        XCTAssertEqual(test.uint8, 1)
        XCTAssertEqual(test.uint16, 0) // excluded
        XCTAssertEqual(test.nested, .init(uint8: 1, nested: .init(uint16: 0, uint32: 3) , uint64: 72057598383227649))
        XCTAssertEqual(test.uint32, 3)
        XCTAssertEqual(test.uint64, 72057598383227649)
        XCTAssertEqual(test.bool, false)
        XCTAssertEqual(test.string, "test")
        
        XCTAssertEqual([UInt8](try test.serialize()), array)
    }
}
