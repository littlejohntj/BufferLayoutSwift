//
//  BufferLayout.swift
//  BufferLayoutSwift
//
//  Created by Chung Tran on 05/08/2021.
//

import Foundation
import Runtime

public enum Error: Swift.Error {
    case bytesLengthIsNotValid
    case propertyIsNotBufferLayoutProperty(propertyName: String)
}

public protocol BufferLayoutProperty {
    var length: Int {get}
    func fromBytes(bytes: [UInt8]) throws -> Self
}

extension UInt8: BufferLayoutProperty {
    public var length: Int {1}
    
    public func fromBytes(bytes: [UInt8]) throws -> UInt8 {
        guard bytes.count == 1 else {throw Error.bytesLengthIsNotValid}
        return bytes.first!
    }
}

public protocol BufferLayout {}

public extension BufferLayout {
    init(data: Data) throws {
        let info = try typeInfo(of: Self.self)
        var selfInstance: Self = try createInstance()
        
        var pointer: Int = 0
        for property in info.properties {
            let instance = try createInstance(of: property.type)
            
            if instance is BufferLayoutProperty {
                let bufferLayoutProperty = instance as! BufferLayoutProperty
                
                let newValue = try bufferLayoutProperty.fromBytes(bytes: data.bytes[pointer..<pointer+bufferLayoutProperty.length].toArray())
                
                let newProperty = try info.property(named: property.name)
                try newProperty.set(value: newValue, on: &selfInstance)
                
                pointer += bufferLayoutProperty.length
            } else {
                throw Error.propertyIsNotBufferLayoutProperty(propertyName: property.name)
            }
        }
        self = selfInstance
    }
}

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
