//
//  File.swift
//  
//
//  Created by Chung Tran on 06/08/2021.
//

import Foundation

public protocol BufferLayoutProperty {
    static func fromData(_ data: Data) throws -> (value: Self, bytesUsed: Int)
    func encode() throws -> Data
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
    public static func fromData(_ data: Data) throws -> (value: Self, bytesUsed: Int) {
        let size = MemoryLayout<Self>.size
        guard data.count >= size else {
            throw Error.bytesLengthIsNotValid
        }
        let data = Array(data[0..<size])
        return (value: data.toUInt(ofType: Self.self), bytesUsed: size)
    }
    
    public func encode() throws -> Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Self>.size)
    }
}

extension Bool: BufferLayoutProperty {
    public static func fromData(_ data: Data) throws -> (value: Bool, bytesUsed: Int) {
        guard data.count >= 1 else {
            throw Error.bytesLengthIsNotValid
        }
        return (value: data.first! != 0, bytesUsed: 1)
    }
    
    public func encode() throws -> Data {
        var int: [UInt8] = [self ? 1: 0]
        return Data(bytes: &int, count: 1)
    }
}

extension Optional: BufferLayoutProperty where Wrapped: BufferLayoutProperty {
    public static func fromData(_ data: Data) throws -> (value: Optional<Wrapped>, bytesUsed: Int) {
        guard let wrapped = try? Wrapped.fromData(data) else {
            return (value: nil, bytesUsed: 0)
        }
        return wrapped
    }
    
    public func encode() throws -> Data {
        guard let self = self else {return Data()}
        return try self.encode()
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
