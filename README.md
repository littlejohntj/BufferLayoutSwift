# BufferLayoutSwift

[![CI Status](https://img.shields.io/travis/bigearsenal/BufferLayoutSwift.svg?style=flat)](https://travis-ci.org/bigearsenal/BufferLayoutSwift)
[![Version](https://img.shields.io/cocoapods/v/BufferLayoutSwift.svg?style=flat)](https://cocoapods.org/pods/BufferLayoutSwift)
[![License](https://img.shields.io/cocoapods/l/BufferLayoutSwift.svg?style=flat)](https://cocoapods.org/pods/BufferLayoutSwift)
[![Platform](https://img.shields.io/cocoapods/p/BufferLayoutSwift.svg?style=flat)](https://cocoapods.org/pods/BufferLayoutSwift)

## What is it?
This library is a clear way to parse sequence of bytes (Data) into your custom struct in order. See [buffer-layout-js](https://www.npmjs.com/package/buffer-layout) for more informations. 

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

BufferLayoutSwift is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BufferLayoutSwift'
```

Define your struct which conforms to `BufferLayout` and all properties conform to `BufferLayoutProperty`. Note that `UInt8`, `UInt16`, `UInt32` are already conformed to `BufferLayoutProperty` by default

```swift
private struct MyStruct: BufferLayout {
    var uint8: UInt8
    var uint16: UInt16
    var uint32: UInt32
    var uint64: UInt64
    var int32: Int32
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
```

You can define custom `BufferLayoutProperty` by conforming your type to `BufferLayoutProperty`:



## Dependencies
1. 'Runtime'

## Author

Chung Tran, bigearsenal@gmail.com

## License

BufferLayoutSwift is available under the MIT license. See the LICENSE file for more info.
