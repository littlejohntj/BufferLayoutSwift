//
//  File.swift
//  
//
//  Created by Chung Tran on 06/08/2021.
//

import Foundation

struct VecU8: BufferLayoutVectorType {
    static func fromBytes(bytes: [UInt8]) throws -> VecU8 {
        let data = Data(capacity: bytes.count)
        return .init(data: data)
    }
    
    static var numberOfBytesToStoreLength: Int {4}
    let data: Data
}
