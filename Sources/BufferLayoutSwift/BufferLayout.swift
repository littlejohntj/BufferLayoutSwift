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
    init(buffer: Data, pointer: inout Int) throws {
        let info = try typeInfo(of: Self.self)
        var selfInstance: Self = try createInstance()
        
        for property in info.properties {
            if Self.excludedPropertyNames.contains(property.name) {continue}
            
            let instanceInfo = try typeInfo(of: property.type)
            
            if let t = instanceInfo.type as? BufferLayoutDeserializable.Type
            {
                if pointer > buffer.count {
                    throw Error.bytesLengthIsNotValid
                }
                
                if property.name == "creators" {
                    pointer += 1
                }
                
                let newValue = try t.init(buffer: buffer, pointer: &pointer)
                
                let newProperty = try info.property(named: property.name)
                try newProperty.set(value: newValue, on: &selfInstance)
            }
        }
        try Self.injectOtherProperties(typeInfo: info, currentInstance: &selfInstance)
        self = selfInstance
    }
    
    func serialize() throws -> Data {
        let info = try typeInfo(of: Self.self)
        var data = Data()
        for property in info.properties {
            if Self.excludedPropertyNames.contains(property.name) {continue}
            let instance = try property.get(from: self)
            if let instance = instance as? BufferLayoutSerializable
            {
                data.append(try instance.serialize())
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
