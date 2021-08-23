//
//  BufferLayout.swift
//  BufferLayoutSwift
//
//  Created by Chung Tran on 05/08/2021.
//

import Foundation
import Runtime

// MARK: - BufferLayout
public protocol BufferLayout: BufferLayoutProperty {
    static func injectOtherProperties(typeInfo: TypeInfo, currentInstance: inout Self) throws
    static var excludedPropertyNames: [String] {get}
}

public extension BufferLayout {
    static func fromData(_ data: Data) throws -> (value: Self, bytesUsed: Int) {
        let info = try typeInfo(of: Self.self)
        var selfInstance: Self = try createInstance()
        
        var data = data
        var bytesUsed = 0
        for property in info.properties {
            if Self.excludedPropertyNames.contains(property.name) {continue}
            
            let instanceInfo = try typeInfo(of: property.type)
            
            if let t = instanceInfo.type as? BufferLayoutProperty.Type
            {
                let createInstance = try t.fromData(data)
                let newValue = createInstance.value
                
                let newProperty = try info.property(named: property.name)
                try newProperty.set(value: newValue, on: &selfInstance)
                
                let bytesUsedByT = createInstance.bytesUsed
                bytesUsed += bytesUsedByT
                
                if bytesUsedByT > data.count {
                    throw Error.bytesLengthIsNotValid
                }
                
                data = Data(Array(data[bytesUsedByT...]))
                
            }
        }
        try Self.injectOtherProperties(typeInfo: info, currentInstance: &selfInstance)
        
        return (value: selfInstance, bytesUsed: bytesUsed)
    }
    
    func encode() throws -> Data {
        let info = try typeInfo(of: Self.self)
        var data = Data()
        for property in info.properties {
            if Self.excludedPropertyNames.contains(property.name) {continue}
            let instance = try property.get(from: self)
            if let instance = instance as? BufferLayoutProperty
            {
                data.append(try instance.encode())
            }
        }
        return data
    }
    
    static func injectOtherProperties(typeInfo: TypeInfo, currentInstance: inout Self) throws {}
    static var excludedPropertyNames: [String] {[]}
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
