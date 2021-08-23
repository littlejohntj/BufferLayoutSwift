//
//  File.swift
//  
//
//  Created by Chung Tran on 23/08/2021.
//

import Foundation

/// A type that can deserialize values from a native format into in-memory
/// representations.
public protocol Deserializer {
    /// The path of serializing keys taken to get to this point in deserializing.
    var codingPath: [CodingKey] { get }

    /// Any contextual information set by the user for deserializing.
    var userInfo: [CodingUserInfoKey : Any] { get }

    /// Returns the data stored in this deserializer as represented in a container
    /// keyed by the given key type.
    ///
    /// - parameter type: The key type to use for the container.
    /// - returns: A keyed deserializing container view into this deserializer.
    /// - throws: `DeserializingError.typeMismatch` if the encountered stored value is
    ///   not a keyed container.
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDeserializingContainer<Key> where Key : CodingKey

    /// Returns the data stored in this deserializer as represented in a container
    /// appropriate for holding values with no keys.
    ///
    /// - returns: An unkeyed container view into this deserializer.
    /// - throws: `DeserializingError.typeMismatch` if the encountered stored value is
    ///   not an unkeyed container.
    func unkeyedContainer() throws -> UnkeyedDeserializingContainer

    /// Returns the data stored in this deserializer as represented in a container
    /// appropriate for holding a single primitive value.
    ///
    /// - returns: A single value container view into this deserializer.
    /// - throws: `DeserializingError.typeMismatch` if the encountered stored value is
    ///   not a single value container.
    func singleValueContainer() throws -> SingleValueDeserializingContainer
}

/// A concrete container that provides a view into a deserializer's storage, making
/// the encoded properties of a decodable type accessible by keys.
public struct KeyedDeserializingContainer<Key: CodingKey> : KeyedDeserializingContainerProtocol {
    public var codingPath: [CodingKey]
    
    public var allKeys: [Key]
    
    public func deserialize<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Deserializable {
        <#code#>
    }
    
    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDeserializingContainer<NestedKey> where NestedKey : CodingKey {
        <#code#>
    }
    
    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDeserializingContainer {
        <#code#>
    }
    
    public func superDeserializer() throws -> Deserializer {
        <#code#>
    }
    
    public func superDeserializer(forKey key: Key) throws -> Deserializer {
        <#code#>
    }
}

/// A type that provides a view into a deserializer's storage and is used to hold
/// the encoded properties of a decodable type in a keyed manner.
///
/// Deserializers should provide types conforming to `UnkeyedDeserializingContainer` for
/// their format.
public protocol KeyedDeserializingContainerProtocol {

    associatedtype Key : CodingKey

    /// The path of serializing keys taken to get to this point in deserializing.
    var codingPath: [CodingKey] { get }

    /// All the keys the `Deserializer` has for this container.
    ///
    /// Different keyed containers from the same `Deserializer` may return different
    /// keys here; it is possible to encode with multiple key types which are
    /// not convertible to one another. This should report all keys present
    /// which are convertible to the requested type.
    var allKeys: [Self.Key] { get }

    /// Decodes a value of the given type for the given key.
    ///
    /// - parameter type: The type of value to deserialize.
    /// - parameter key: The key that the deserialized value is associated with.
    /// - returns: A value of the requested type, if present for the given key
    ///   and convertible to the requested type.
    /// - throws: `DeserializingError.typeMismatch` if the encountered encoded value
    ///   is not convertible to the requested type.
    /// - throws: `DeserializingError.keyNotFound` if `self` does not have an entry
    ///   for the given key.
    /// - throws: `DeserializingError.valueNotFound` if `self` has a null entry for
    ///   the given key.
    func deserialize<T>(_ type: T.Type, forKey key: Self.Key) throws -> T where T : Deserializable

    /// Returns the data stored for the given key as represented in a container
    /// keyed by the given key type.
    ///
    /// - parameter type: The key type to use for the container.
    /// - parameter key: The key that the nested container is associated with.
    /// - returns: A keyed deserializing container view into `self`.
    /// - throws: `DeserializingError.typeMismatch` if the encountered stored value is
    ///   not a keyed container.
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Self.Key) throws -> KeyedDeserializingContainer<NestedKey> where NestedKey : CodingKey

    /// Returns the data stored for the given key as represented in an unkeyed
    /// container.
    ///
    /// - parameter key: The key that the nested container is associated with.
    /// - returns: An unkeyed deserializing container view into `self`.
    /// - throws: `DeserializingError.typeMismatch` if the encountered stored value is
    ///   not an unkeyed container.
    func nestedUnkeyedContainer(forKey key: Self.Key) throws -> UnkeyedDeserializingContainer

    /// Returns a `Deserializer` instance for deserializing `super` from the container
    /// associated with the default `super` key.
    ///
    /// Equivalent to calling `superDeserializer(forKey:)` with
    /// `Key(stringValue: "super", intValue: 0)`.
    ///
    /// - returns: A new `Deserializer` to pass to `super.init(from:)`.
    /// - throws: `DeserializingError.keyNotFound` if `self` does not have an entry
    ///   for the default `super` key.
    /// - throws: `DeserializingError.valueNotFound` if `self` has a null entry for
    ///   the default `super` key.
    func superDeserializer() throws -> Deserializer

    /// Returns a `Deserializer` instance for deserializing `super` from the container
    /// associated with the given key.
    ///
    /// - parameter key: The key to deserialize `super` for.
    /// - returns: A new `Deserializer` to pass to `super.init(from:)`.
    /// - throws: `DeserializingError.keyNotFound` if `self` does not have an entry
    ///   for the given key.
    /// - throws: `DeserializingError.valueNotFound` if `self` has a null entry for
    ///   the given key.
    func superDeserializer(forKey key: Self.Key) throws -> Deserializer
}

public protocol UnkeyedDeserializingContainer {
    /// The path of serializing keys taken to get to this point in deserializing.
    var codingPath: [CodingKey] { get }

    /// The number of elements contained within this container.
    ///
    /// If the number of elements is unknown, the value is `nil`.
    var count: Int? { get }

    /// A Boolean value indicating whether there are no more elements left to be
    /// deserialized in the container.
    var isAtEnd: Bool { get }

    /// The current deserializing index of the container (i.e. the index of the next
    /// element to be deserialized.) Incremented after every successful deserialize call.
    var currentIndex: Int { get }
    
    /// Decodes a single value of the given type.
    ///
    /// - parameter type: The type to deserialize as.
    /// - returns: A value of the requested type.
    /// - throws: `DeserializingError.typeMismatch` if the encountered encoded value
    ///   cannot be converted to the requested type.
    /// - throws: `DeserializingError.valueNotFound` if the encountered encoded value
    ///   is null.
    mutating func deserialize<T: Deserializable>(_ type: T.Type) throws -> T
    
    /// Decodes a nested container keyed by the given type.
    ///
    /// - parameter type: The key type to use for the container.
    /// - returns: A keyed deserializing container view into `self`.
    /// - throws: `DeserializingError.typeMismatch` if the encountered stored value is
    ///   not a keyed container.
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDeserializingContainer<NestedKey> where NestedKey : CodingKey

    /// Decodes an unkeyed nested container.
    ///
    /// - returns: An unkeyed deserializing container view into `self`.
    /// - throws: `DeserializingError.typeMismatch` if the encountered stored value is
    ///   not an unkeyed container.
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDeserializingContainer

    /// Decodes a nested container and returns a `Deserializer` instance for deserializing
    /// `super` from that container.
    ///
    /// - returns: A new `Deserializer` to pass to `super.init(from:)`.
    /// - throws: `DeserializingError.valueNotFound` if the encountered encoded value
    ///   is null, or of there are no more values to deserialize.
    mutating func superDeserializer() throws -> Deserializer
}

/// A container that can support the storage and direct deserializing of a single
/// nonkeyed value.
public protocol SingleValueDeserializingContainer {

    /// The path of serializing keys taken to get to this point in enserializing.
    var codingPath: [CodingKey] { get }
    
    /// Decodes a single value of the given type.
    ///
    /// - parameter type: The type to deserialize as.
    /// - returns: A value of the requested type.
    /// - throws: `DeserializingError.typeMismatch` if the encountered encoded value
    ///   cannot be converted to the requested type.
    /// - throws: `DeserializingError.valueNotFound` if the encountered encoded value
    ///   is null.
    func deserialize<T: Deserializable>(_ type: T.Type) throws -> T
}
