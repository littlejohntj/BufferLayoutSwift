//
//  File.swift
//  
//
//  Created by Chung Tran on 23/08/2021.
//

import Foundation

/// A type that can encode values into a native format for external
/// representation.
public protocol Serializer {
    /// The path of coding keys taken to get to this point in encoding.
    var codingPath: [CodingKey] { get }

    /// Any contextual information set by the user for encoding.
    var userInfo: [CodingUserInfoKey : Any] { get }

    /// Returns an encoding container appropriate for holding multiple values
    /// keyed by the given key type.
    ///
    /// You must use only one kind of top-level encoding container. This method
    /// must not be called after a call to `unkeyedContainer()` or after
    /// encoding a value through a call to `singleValueContainer()`
    ///
    /// - parameter type: The key type to use for the container.
    /// - returns: A new keyed encoding container.
    func container<Key>(keyedBy type: Key.Type) -> KeyedSerializingContainer<Key> where Key : CodingKey

    /// Returns an encoding container appropriate for holding multiple unkeyed
    /// values.
    ///
    /// You must use only one kind of top-level encoding container. This method
    /// must not be called after a call to `container(keyedBy:)` or after
    /// encoding a value through a call to `singleValueContainer()`
    ///
    /// - returns: A new empty unkeyed container.
    func unkeyedContainer() -> UnkeyedSerializingContainer

    /// Returns an encoding container appropriate for holding a single primitive
    /// value.
    ///
    /// You must use only one kind of top-level encoding container. This method
    /// must not be called after a call to `unkeyedContainer()` or
    /// `container(keyedBy:)`, or after encoding a value through a call to
    /// `singleValueContainer()`
    ///
    /// - returns: A new empty single value container.
    func singleValueContainer() -> SingleValueEncodingContainer
}

/// A concrete container that provides a view into an encoder's storage, making
/// the encoded properties of an encodable type accessible by keys.
public struct KeyedSerializingContainer<Key: CodingKey> : KeyedSerializingContainerProtocol {
    public var codingPath: [CodingKey]
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedSerializingContainer<NestedKey> where NestedKey : CodingKey {
        <#code#>
    }
    
    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedSerializingContainer {
        <#code#>
    }
    
    public mutating func superSerializer() -> Serializer {
        <#code#>
    }
    
    public mutating func superSerializer(forKey key: Key) -> Serializer {
        <#code#>
    }
}

/// A type that provides a view into an encoder's storage and is used to hold
/// the encoded properties of an encodable type in a keyed manner.
///
/// Encoders should provide types conforming to
/// `KeyedSerializingContainerProtocol` for their format.
public protocol KeyedSerializingContainerProtocol {

    associatedtype Key : CodingKey

    /// The path of coding keys taken to get to this point in encoding.
    var codingPath: [CodingKey] { get }
    
    /// Stores a keyed encoding container for the given key and returns it.
    ///
    /// - parameter keyType: The key type to use for the container.
    /// - parameter key: The key to encode the container for.
    /// - returns: A new keyed encoding container.
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Self.Key) -> KeyedSerializingContainer<NestedKey> where NestedKey : CodingKey

    /// Stores an unkeyed encoding container for the given key and returns it.
    ///
    /// - parameter key: The key to encode the container for.
    /// - returns: A new unkeyed encoding container.
    mutating func nestedUnkeyedContainer(forKey key: Self.Key) -> UnkeyedSerializingContainer

    /// Stores a new nested container for the default `super` key and returns a
    /// new encoder instance for encoding `super` into that container.
    ///
    /// Equivalent to calling `superEncoder(forKey:)` with
    /// `Key(stringValue: "super", intValue: 0)`.
    ///
    /// - returns: A new encoder to pass to `super.encode(to:)`.
    mutating func superSerializer() -> Serializer

    /// Stores a new nested container for the given key and returns a new encoder
    /// instance for encoding `super` into that container.
    ///
    /// - parameter key: The key to encode `super` for.
    /// - returns: A new encoder to pass to `super.encode(to:)`.
    mutating func superSerializer(forKey key: Self.Key) -> Serializer
}

/// A type that provides a view into an encoder's storage and is used to hold
/// the encoded properties of an encodable type sequentially, without keys.
///
/// Encoders should provide types conforming to `UnkeyedEncodingContainer` for
/// their format.
public protocol UnkeyedSerializingContainer {

    /// The path of coding keys taken to get to this point in encoding.
    var codingPath: [CodingKey] { get }

    /// The number of elements encoded into the container.
    var count: Int { get }
    
    /// Encodes the given value.
    ///
    /// - parameter value: The value to encode.
    /// - throws: `EncodingError.invalidValue` if the given value is invalid in
    ///   the current context for this format.
    mutating func serialize<T: Serializable>(_ value: T) throws
    
    /// Encodes a nested container keyed by the given type and returns it.
    ///
    /// - parameter keyType: The key type to use for the container.
    /// - returns: A new keyed encoding container.
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedSerializingContainer<NestedKey> where NestedKey : CodingKey

    /// Encodes an unkeyed encoding container and returns it.
    ///
    /// - returns: A new unkeyed encoding container.
    mutating func nestedUnkeyedContainer() -> UnkeyedSerializingContainer

    /// Encodes a nested container and returns an `Encoder` instance for encoding
    /// `super` into that container.
    ///
    /// - returns: A new encoder to pass to `super.encode(to:)`.
    mutating func superSerializer() -> Serializer
}

/// A container that can support the storage and direct encoding of a single
/// non-keyed value.
public protocol SingleValueEncodingContainer {

    /// The path of coding keys taken to get to this point in encoding.
    var codingPath: [CodingKey] { get }

    mutating func deserialize<T: Serializable>(_ value: T) throws
}
