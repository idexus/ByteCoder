//
//  ByteEncoder.swift
//  ByteCoder
//
//  Created by Pawel Krzywdzinski on 16/10/2018.
//  Copyright (c) 2018 Pawel Krzywdzinski
//

import Foundation

/// Data container class of `ByteEncoder`
fileprivate class EncoderBuffer {
    var data: [UInt8]
    init (minimumCapacity: Int) {
        self.data = [UInt8]()
        self.data.reserveCapacity(minimumCapacity)
    }
}

/// Responsible for encoding `ByteEncodeable` classes to [UInt8] buffer
public class ByteEncoder {
    fileprivate var encoderBuffer: EncoderBuffer
    
    /// `ByteEncoder` consts
    public struct Const {
        /// Default `encoderBuffer` minimum capacity
        public static let defaultMinimumCapacity = 16
    }
    
    public init(minimumCapacity: Int = Const.defaultMinimumCapacity) {
        self.encoderBuffer = EncoderBuffer(minimumCapacity: minimumCapacity)
    }
    
    fileprivate init(buffer: EncoderBuffer) {
        self.encoderBuffer = buffer
    }
}

/// main `encode` function
public extension ByteEncoder {
    
    public var encodedData: [UInt8] { return encoderBuffer.data }
    
    public func removeEncodedData() {
        encoderBuffer.data.removeAll()
    }
    
    /// Encode `value` to `[UInt]` buffer.
    ///
    /// - parameters:
    ///     - value: `Encodable` value to encode.
    ///
    /// - returns: Encoded `[UInt8]` array.
    ///
    public func encode(_ value: Encodable) throws -> [UInt8] {
        self.encoderBuffer.data.reserveCapacity(self.encoderBuffer.data.count + value.sizeForByteCoder)
        try value.encode(to: self)
        return self.encoderBuffer.data
    }
}

public extension ByteEncoder {
    /// `ByteEncoder` errors.
    enum Error : Swift.Error {
        case notSupported
    }
}

public extension ByteEncoder {
    
    fileprivate func encodeToCString(_ value: String) {
        var data = Array(value.utf8)
        data.append(0)
        self.encoderBuffer.data.append(contentsOf: data)
    }
    
    /// Encode RAW values into buffer (e.g. Int, Double, Float...)
    ///
    /// - parameters:
    ///     - value: RAW value to encode (e.g. Int, Double, Float...)
    ///
    fileprivate func encodeRawValue<T>(_ value: T) {
        var source = value
        withUnsafeBytes(of: &source) {
            self.encoderBuffer.data.append(contentsOf: $0)
        }
    }
}

/// `Encoder` protocol extension
extension ByteEncoder: Encoder {
    public var codingPath: [CodingKey] { return [] }
    
    public var userInfo: [CodingUserInfoKey : Any] { return [:] }
    
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(KeyedContainer<Key>(encoder: self))
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        return UnkeyedContanier(encoder: self)
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return SingleValueContainer(encoder: self)
    }
    
    private struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        var encoder: ByteEncoder
        
        var codingPath: [CodingKey] { return [] }
        
        mutating func encodeNil(forKey key: Key) throws {
            throw ByteEncoder.Error.notSupported
        }
        
        mutating func encode(_ value: String, forKey key: Key) throws {
            encoder.encodeToCString(value)
        }

        mutating func encode(_ value: Bool, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Double, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Float, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int8, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int16, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int32, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int64, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt8, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt16, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt32, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt64, forKey key: Key) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            let encoder = ByteEncoder.init(buffer: self.encoder.encoderBuffer)
            try value.encode(to: encoder)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return encoder.container(keyedBy: keyType)
        }
        
        mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            return encoder.unkeyedContainer()
        }
        
        mutating func superEncoder() -> Encoder {
            return encoder
        }
        
        mutating func superEncoder(forKey key: Key) -> Encoder {
            return encoder
        }
    }
    
    private struct SingleValueContainer: SingleValueEncodingContainer {
        var encoder: ByteEncoder
        
        var codingPath: [CodingKey] { return [] }
        
        mutating func encodeNil() throws {
            throw ByteEncoder.Error.notSupported
        }
        
        mutating func encode(_ value: String) throws {
            encoder.encodeToCString(value)
        }
        
        mutating func encode(_ value: Bool) throws {
            encoder.encodeRawValue(value)
        }

        mutating func encode(_ value: Double) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Float) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int8) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int16) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int32) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int64) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt8) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt16) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt32) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt64) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode<T>(_ value: T) throws where T : Encodable {
            let encoder = ByteEncoder.init(buffer: self.encoder.encoderBuffer)
            try value.encode(to: encoder)
        }
    }
    
    private struct UnkeyedContanier: UnkeyedEncodingContainer {
        var encoder: ByteEncoder
        
        var codingPath: [CodingKey] { return [] }
        
        var count: Int { return 0 }

        
        mutating func encodeNil() throws {
            throw ByteEncoder.Error.notSupported
        }
        
        mutating func encode(_ value: String) throws {
            encoder.encodeToCString(value)
        }
        
        mutating func encode(_ value: Bool) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Double) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Float) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int8) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int16) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int32) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: Int64) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt8) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt16) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt32) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode(_ value: UInt64) throws {
            encoder.encodeRawValue(value)
        }
        
        mutating func encode<T>(_ value: T) throws where T : Encodable {
            let encoder = ByteEncoder.init(buffer: self.encoder.encoderBuffer)
            try value.encode(to: encoder)
        }

        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            return encoder.container(keyedBy: keyType)
        }
        
        mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            return self
        }
        
        mutating func superEncoder() -> Encoder {
            return encoder
        }
    }
}

