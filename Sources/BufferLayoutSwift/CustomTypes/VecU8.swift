//
//  File.swift
//  
//
//  Created by Chung Tran on 06/08/2021.
//

import Foundation

public struct VecU8: BufferLayoutVectorType {
    public static func fromBytes(bytes: [UInt8], length: Int) throws -> VecU8 {
        return .init(bytes: bytes, length: length)
    }
    
    public static var numberOfBytesToStoreLength: Int {4}
    public let bytes: [UInt8]
    public let length: Int
}
