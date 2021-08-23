# BufferLayoutSwift

[![CI Status](https://img.shields.io/travis/bigearsenal/BufferLayoutSwift.svg?style=flat)](https://travis-ci.org/bigearsenal/BufferLayoutSwift)
[![Version](https://img.shields.io/cocoapods/v/BufferLayoutSwift.svg?style=flat)](https://cocoapods.org/pods/BufferLayoutSwift)
[![License](https://img.shields.io/cocoapods/l/BufferLayoutSwift.svg?style=flat)](https://cocoapods.org/pods/BufferLayoutSwift)
[![Platform](https://img.shields.io/cocoapods/p/BufferLayoutSwift.svg?style=flat)](https://cocoapods.org/pods/BufferLayoutSwift)

## What is it?
This library is a clear way to parse sequence of bytes (Data) into your custom struct in order. See [buffer-layout-js](https://www.npmjs.com/package/buffer-layout) for more informations. 

## Example

To run the tests, clone the repo, and run `pod install` from the Example directory first.

Example decoding a struct from sequence of bytes:
```swift
let bytes: [UInt8] = [
    3,0,0,0,1,2,3, // a vector with length = 3 (3,0,0,0) 
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
```

```swift
private struct VecU8: BufferLayoutProperty {
    let length: UInt32
    let bytes: [UInt8]
    
    static func fromData(_ data: Data) throws -> (value: VecU8, bytesUsed: Int) {
        // first 4 bytes for length
        let length = try UInt32.fromData(data).value
        guard data.count >= 4+Int(length) else {
            throw BufferLayoutSwift.Error.bytesLengthIsNotValid
        }
        let value = VecU8(length: length, bytes: Array(data[4..<4+Int(length)]))
        return (value: value, bytesUsed: 4 + Int(length))
    }
    
    func encode() throws -> Data {
        try length.encode() +
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
```

```swift
let test = try MyNumberCollection.fromData(Data(array)).value
XCTAssertEqual(test.vecu8.bytes, [1,2,3])
XCTAssertEqual(test.uint128, 4)
XCTAssertEqual(test.uint8, 1)
XCTAssertEqual(test.uint16, 0) // excluded
XCTAssertEqual(test.nested, .init(uint8: 1, nested: .init(uint16: 0, uint32: 3) , uint64: 72057598383227649))
XCTAssertEqual(test.uint32, 3)
XCTAssertEqual(test.uint64, 72057598383227649)
XCTAssertEqual(test.bool, false)
XCTAssertEqual(test.string, "test")

XCTAssertEqual([UInt8](try test.encode()), array)
```

## Requirements

## Installation

BufferLayoutSwift is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BufferLayoutSwift'
```

Define your struct which conforms to `BufferLayout` and all properties conform to `BufferLayoutProperty`. Note that `UInt8`, `UInt16`, `UInt32`, ... are already conformed to `BufferLayoutProperty` by default.

```swift
private struct MyStruct: BufferLayout {
    var uint8: UInt8
    var uint16: UInt16
    var uint32: UInt32
    var uint64: UInt64
    var int32: Int32
}
```

If you want to exclude some properties from parsing, you can add `excludedPropertyNames: [String]` to your struct. All these properties and non-`BufferLayoutProperty` will be ignored.

```swift
private struct MyStruct: BufferLayout {
    ...
    static var excludedPropertyNames: [String] {["uint16"]}
}
```

If you want to modify some non-parsable property after parsing needed properties from data, implement optional method `static func injectOtherProperties(typeInfo: TypeInfo, currentInstance: inout MyStruct) throws`. This function will be called on the bottom of `init(buffer:)`. 
Example:

```swift
private struct MyStruct: BufferLayout {
    ...
    static func injectOtherProperties(typeInfo: TypeInfo, currentInstance: inout MyStruct) throws {
        let stringProp = try typeInfo.property(named: "myProperty") // get property 
        try stringProp.set(value: "test", on: &currentInstance) // dynamically set its property
    }
}
```

Now you can create instances of `MyStruct` by calling fallable `init(data: Data) throws`. See example for more informations

## Supported `BufferLayoutProperty`:

There are some prefined `BufferLayoutProperty` , note that `BufferLayout` is also conform to `BufferLayoutProperty` for recursion.

```swift
extension UInt8: BufferLayoutProperty {}
extension UInt16: BufferLayoutProperty {}
extension UInt32: BufferLayoutProperty {}
extension UInt64: BufferLayoutProperty {}

extension Int8: BufferLayoutProperty {}
extension Int16: BufferLayoutProperty {}
extension Int32: BufferLayoutProperty {}
extension Int64: BufferLayoutProperty {}

extension Bool: BufferLayoutProperty {}
extension Optional: BufferLayoutProperty where Wrapped: BufferLayoutProperty {}
```

You can define custom `BufferLayoutProperty` by conforming your type to `BufferLayoutProperty`. For example: get `PublicKey` from buffer layout with 32 bytes:

```swift
extension PublicKey: BufferLayoutProperty {
    public static func getNumberOfBytes() throws -> Int {
        32
    }

    public init(buffer: Data) throws {
        guard bytes.count == numberOfBytes else {
            throw BufferLayoutSwift.Error.bytesLengthIsNotValid
        }
        // return public key from data
        self = buffer.toPublicKey()
    }

    public func encode() throws -> Data {
        ...
    }
}
```

## Dependencies
1. 'Runtime'

## Author

Chung Tran, bigearsenal@gmail.com

## License

BufferLayoutSwift is available under the MIT license. See the LICENSE file for more info.
