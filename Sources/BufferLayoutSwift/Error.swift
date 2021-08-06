//
//  File.swift
//  
//
//  Created by Chung Tran on 06/08/2021.
//

import Foundation

public enum Error: Swift.Error {
    case bytesLengthIsNotValid
    case unsupportedType(type: Any.Type, propertyName: String)
}
