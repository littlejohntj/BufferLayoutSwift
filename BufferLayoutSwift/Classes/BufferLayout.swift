//
//  BufferLayout.swift
//  BufferLayoutSwift
//
//  Created by Chung Tran on 05/08/2021.
//

import Foundation
import Runtime

// MARK: - Errors
public enum Error: Swift.Error {
    case bytesLengthIsNotValid
    case unsupportedType(type: Any.Type, propertyName: String)
}

// MARK: - BufferLayoutProperties
public protocol BufferLayoutProperty {
    static var numberOfBytes: Int {get}
    static func fromBytes(bytes: [UInt8]) throws -> Self
}

extension UInt8: BufferLayoutProperty {}
extension UInt16: BufferLayoutProperty {}
extension UInt32: BufferLayoutProperty {}
extension UInt64: BufferLayoutProperty {}

extension Int8: BufferLayoutProperty {}
extension Int16: BufferLayoutProperty {}
extension Int32: BufferLayoutProperty {}
extension Int64: BufferLayoutProperty {}

extension FixedWidthInteger {
    public static var numberOfBytes: Int {
        MemoryLayout<Self>.size
    }
    public static func fromBytes(bytes: [UInt8]) throws -> Self {
        guard bytes.count == numberOfBytes else {
            throw Error.bytesLengthIsNotValid
        }
        return bytes.toUInt(ofType: Self.self)
    }
}

// MARK: - BufferLayout
public protocol BufferLayout {}

public extension BufferLayout {
    init(buffer data: Data) throws {
        let info = try typeInfo(of: Self.self)
        var selfInstance: Self = try createInstance()
        
        var pointer: Int = 0
        for property in info.properties {
            print(property.name)
            let instanceInfo = try typeInfo(of: property.type)
            if let t = instanceInfo.type as? BufferLayoutProperty.Type
            {
                guard pointer+t.numberOfBytes <= data.bytes.count else {
                    throw Error.bytesLengthIsNotValid
                }
                let newValue = try t.fromBytes(
                    bytes: data
                        .bytes[pointer..<pointer+t.numberOfBytes]
                        .toArray()
                )
                
                let newProperty = try info.property(named: property.name)
                try newProperty.set(value: newValue, on: &selfInstance)
                
                pointer += t.numberOfBytes
            } else {
                throw Error.unsupportedType(type: property.type, propertyName: property.name)
            }
        }
        self = selfInstance
    }
}

// MARK: - Helpers
private extension Data {
    var bytes: Array<UInt8> {
        Array(self)
    }
}

private extension ArraySlice {
    func toArray() -> [Element] {
        Array(self)
    }
}

private extension Array where Element == UInt8 {
    func toUInt<T: FixedWidthInteger>(ofType: T.Type) -> T {
        let data = Data(self)
        return T(littleEndian: data.withUnsafeBytes { $0.load(as: T.self) })
    }
    
    func toInt() -> Int {
        var value: Int = 0
        for byte in self {
            value = value << 8
            value = value | Int(byte)
        }
        return value
    }
}
