//
//  ByteDecoder.swift
//  ByteCoder
//
//  Created by Pawel Krzywdzinski on 16/10/2018.
//  Copyright (c) 2018 Pawel Krzywdzinski
//

import Foundation

fileprivate class DecoderBuffer: Encodable {
    var data = [UInt8]()
    var pos = 0
}

public class ByteDecoder {
    fileprivate var buffer: DecoderBuffer
    
    public init(data: [UInt8]) {
        self.buffer = DecoderBuffer()
        self.buffer.data = data
    }
    
    fileprivate init(buffer: DecoderBuffer) {
        self.buffer = buffer
    }
}

public extension ByteDecoder {
    enum Error : Swift.Error {
        case notEnoughData
        case notSupported
        case noCString
    }
}

public extension ByteDecoder {
    public func decodeBytes(count: Int) throws -> [UInt8] {
        guard buffer.pos + count <= buffer.data.count else {
            throw ByteDecoder.Error.notEnoughData
        }
        let dataSlice = Slice<[UInt8]>(base: buffer.data, bounds: buffer.pos..<buffer.pos+count)
        buffer.pos += count
        return [UInt8].init(dataSlice)
    }
    
    public func decodeString(count: Int) throws -> String {
        var stringBytes = try decodeBytes(count: count)
        stringBytes.append(0)
        return String(cString: stringBytes)
    }
    
    private func decodeCString() throws -> String {
        let restDataSlice = Slice<[UInt8]>(base: buffer.data, bounds: buffer.pos..<buffer.data.count)
        guard let indexOfZero = (restDataSlice.firstIndex { $0 == 0 }) else {
            throw ByteDecoder.Error.noCString
        }
        let stringBytes = try decodeBytes(count: indexOfZero - buffer.pos + 1)
        return String(cString: stringBytes)
    }
}


public extension ByteDecoder {
    
    fileprivate func decodeRawValue<T>() throws -> T where T : Decodable {
        
        let sizeOfType = MemoryLayout<T>.size
        guard buffer.pos + sizeOfType <= buffer.data.count else {
            throw ByteDecoder.Error.notEnoughData
        }

        let valueBuffer = UnsafeMutablePointer<T>.allocate(capacity: 1)
        let valueBufferUInt8View = UnsafeMutableRawPointer(valueBuffer).assumingMemoryBound(to: UInt8.self)
        defer {
            valueBuffer.deallocate()
        }
        
        for i in 0..<sizeOfType {
            valueBufferUInt8View[i] = buffer.data[buffer.pos]
            buffer.pos += 1
        }
        
        return valueBuffer.pointee
    }
}

extension ByteDecoder: Decoder {
    public var codingPath: [CodingKey] { return [] }
    
    public var userInfo: [CodingUserInfoKey : Any] { return [:] }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(KeyedContainer<Key>(decoder: self))
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return UnkeyedContainer(decoder: self)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return DecodingContainer(decoder: self)
    }
    
    private struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        var decoder: ByteDecoder
        
        var codingPath: [CodingKey] { return [] }
        
        var allKeys: [Key] { return [] }
        
        func contains(_ key: Key) -> Bool {
            return true
        }
        
        func decodeNil(forKey key: Key) throws -> Bool {
            return false
        }
        
        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            return try decoder.decodeCString()
        }
        
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            return try decoder.decodeRawValue()
        }
        
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            let decoder = ByteDecoder(buffer: self.decoder.buffer)
            return try T(from: decoder)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            return try decoder.container(keyedBy: type)
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            return try decoder.unkeyedContainer()
        }

        func superDecoder() throws -> Decoder {
            return decoder
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            return decoder
        }
    }
    
    private struct DecodingContainer : SingleValueDecodingContainer {
        var decoder: ByteDecoder
        
        var codingPath: [CodingKey] { return [] }
        
        func decodeNil() -> Bool {
            return false
        }
        
        func decode(_ type: String.Type) throws -> String {
            return try decoder.decodeCString()
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            return try decoder.decodeRawValue()
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            return try decoder.decodeRawValue()
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            let decoder = ByteDecoder(buffer: self.decoder.buffer)
            return try T(from: decoder)
        }
    }
 
    private struct UnkeyedContainer: UnkeyedDecodingContainer {
        var decoder: ByteDecoder
        
        var codingPath: [CodingKey] { return [] }
        
        var count: Int? { return 0 }
        
        var isAtEnd: Bool { return false }
        
        var currentIndex: Int { return 0 }
        
        mutating func decodeNil() throws -> Bool {
            throw ByteDecoder.Error.notSupported
        }
        
        mutating func decode(_ type: String.Type) throws -> String {
            return try decoder.decodeCString()
        }
        
        mutating func decode(_ type: Bool.Type) throws -> Bool {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: Double.Type) throws -> Double {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: Float.Type) throws -> Float {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: Int.Type) throws -> Int {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: Int8.Type) throws -> Int8 {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: Int16.Type) throws -> Int16 {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: Int32.Type) throws -> Int32 {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: Int64.Type) throws -> Int64 {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: UInt.Type) throws -> UInt {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            return try decoder.decodeRawValue()
        }
        
        mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            let decoder = ByteDecoder(buffer: self.decoder.buffer)
            return try T(from: decoder)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            return try decoder.container(keyedBy: type)
        }
        
        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            return self
        }
        
        mutating func superDecoder() throws -> Decoder {
            return decoder
        }
    }
}



public extension SingleValueDecodingContainer {
    public func decode<T>() throws -> T where T : Decodable {
        return try decode(T.self)
    }
}

public extension UnkeyedDecodingContainer {
    public mutating func decode<T>() throws -> T where T : Decodable {
        return try decode(T.self)
    }
}
