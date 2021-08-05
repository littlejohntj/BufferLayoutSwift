# BufferLayoutSwift

[![CI Status](https://img.shields.io/travis/bigearsenal/BufferLayoutSwift.svg?style=flat)](https://travis-ci.org/bigearsenal/BufferLayoutSwift)
[![Version](https://img.shields.io/cocoapods/v/BufferLayoutSwift.svg?style=flat)](https://cocoapods.org/pods/BufferLayoutSwift)
[![License](https://img.shields.io/cocoapods/l/BufferLayoutSwift.svg?style=flat)](https://cocoapods.org/pods/BufferLayoutSwift)
[![Platform](https://img.shields.io/cocoapods/p/BufferLayoutSwift.svg?style=flat)](https://cocoapods.org/pods/BufferLayoutSwift)

## What is it?
This library is a clear way to parse sequence of bytes (Data) into your custom struct in order. See [buffer-layout-js](https://www.npmjs.com/package/buffer-layout) for more informations. 

## Example

To run the tests, clone the repo, and run `pod install` from the Example directory first.

Example decoding MyStruct from sequence of bytes (`Data([1,3,0,3,1,0,0,1,3,0,3,1,0,0,1,1,0,0,1,0])`)

```swift
private struct MyStruct: BufferLayout {
    // parsable
    let uint8: UInt8
    let uint16: UInt16 // excluded -> default to 0
    let uint32: UInt32?
    let uint64: UInt64
    let int32: Int32
    let bool: Bool
    
    static var excludedPropertyNames: [String] {["uint16"]}

    // non-parsable part
    var optionalString: String?
    let string: String
    var exGetter: Int {0}
    func exFunc() {}

    static func injectOtherProperties(typeInfo: TypeInfo, currentInstance: inout MyStruct) throws {
        let stringProp = try typeInfo.property(named: "string")
        try stringProp.set(value: "test", on: &currentInstance)
    }
}
```

```swift
let test = try MyStruct(buffer: Data([1,3,1,0,0,1,3,0,3,1,0,0,1,1,0,0,1,0]))
XCTAssertEqual(test.uint8, 1)
XCTAssertEqual(test.uint16, 0)
XCTAssertEqual(test.uint32, 259)
XCTAssertEqual(test.uint64, 72057598383227649)
XCTAssertEqual(test.uint32, 259)
XCTAssertEqual(test.bool, false)
XCTAssertEqual(test.string, "test")
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

There are some prefined `BufferLayoutProperty` 

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
    public static var numberOfBytes: Int {
        32
    }
    public static func fromBytes(bytes: [UInt8]) throws -> PublicKey {
        guard bytes.count == numberOfBytes else {
            throw BufferLayoutSwift.Error.bytesLengthIsNotValid
        }
        // return public key from data
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
