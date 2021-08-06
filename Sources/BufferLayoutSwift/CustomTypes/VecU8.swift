//
//  File.swift
//  
//
//  Created by Chung Tran on 06/08/2021.
//

import Foundation

public struct VecU8: BufferLayoutVectorType {
    public static func fromBytes(bytes: [UInt8]) throws -> VecU8 {
        return .init(bytes: bytes)
    }
    
    public static var numberOfBytesToStoreLength: Int {4}
    public let bytes: [UInt8]
}
