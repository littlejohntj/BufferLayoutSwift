//
//  File.swift
//  
//
//  Created by Chung Tran on 06/08/2021.
//

import Foundation

public protocol BufferLayoutVectorType {
    static var numberOfBytesToStoreLength: Int {get}
    static func fromBytes(bytes: [UInt8]) throws -> Self
}

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

extension Bool: BufferLayoutProperty {
    public static var numberOfBytes: Int { 1 }
    
    public static func fromBytes(bytes: [UInt8]) throws -> Bool {
        guard bytes.count == 1 else {
            throw Error.bytesLengthIsNotValid
        }
        return bytes.first! != 0
    }
}

extension Optional: BufferLayoutProperty where Wrapped: BufferLayoutProperty {
    public static var numberOfBytes: Int {
        Wrapped.numberOfBytes
    }
    
    public static func fromBytes(bytes: [UInt8]) throws -> Optional<Wrapped> {
        guard bytes.count == numberOfBytes else {return nil}
        return try? Wrapped.fromBytes(bytes: bytes)
    }
}

extension Array where Element == UInt8 {
    func toUInt<T: FixedWidthInteger>(ofType: T.Type) -> T {
        let data = Data(self)
        return T(littleEndian: data.withUnsafeBytes { $0.load(as: T.self) })
    }
    
    func toInt() -> Int {
        var value: Int = 0
        for byte in self.reversed() {
            value = value << 8
            value = value | Int(byte)
        }
        return value
    }
}
