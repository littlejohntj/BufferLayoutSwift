//
//  File.swift
//  
//
//  Created by Chung Tran on 23/08/2021.
//

import Foundation

/// A type that can encode itself to an external representation.
public protocol Serializable {

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    func serialize(to serializer: Serializer) throws
}

/// A type that can decode itself from an external representation.
public protocol Deserializable {

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    init(from deserializer: Deserializer) throws
}

/// A type that can convert itself into and out of an external representation.
///
/// `Codable` is a type alias for the `Encodable` and `Decodable` protocols.
/// When you use `Codable` as a type or a generic constraint, it matches
/// any type that conforms to both protocols.
public typealias BufferSerializable = Serializable & Deserializable
