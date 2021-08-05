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
    case propertyIsNotBufferLayoutProperty(propertyName: String)
}

// MARK: - BufferLayoutProperties
public protocol BufferLayoutProperty {
    static var length: Int {get}
    static func fromBytes(bytes: [UInt8]) throws -> Self
}

extension UInt8: BufferLayoutProperty {}
extension UInt16: BufferLayoutProperty {}
extension UInt32: BufferLayoutProperty {}
extension UInt64: BufferLayoutProperty {}

extension FixedWidthInteger {
    public static var length: Int {
        MemoryLayout<Self>.size
    }
    public static func fromBytes(bytes: [UInt8]) throws -> Self {
        guard bytes.count == length else {
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
            let instanceInfo = try typeInfo(of: property.type)
            if let t = instanceInfo.type as? BufferLayoutProperty.Type
            {
                guard pointer+t.length <= data.bytes.count else {
                    throw Error.bytesLengthIsNotValid
                }
                let newValue = try t.fromBytes(
                    bytes: data
                        .bytes[pointer..<pointer+t.length]
                        .toArray()
                )
                
                let newProperty = try info.property(named: property.name)
                try newProperty.set(value: newValue, on: &selfInstance)
                
                pointer += t.length
            } else {
                throw Error.propertyIsNotBufferLayoutProperty(propertyName: property.name)
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
        return T(littleEndian: data.withUnsafeBytes { $0.pointee })
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
