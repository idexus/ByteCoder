//
//  EncodableExtension.swift
//  ByteCoder
//
//  Created by Pawel Krzywdzinski on 17/10/2018.
//  Copyright (c) 2018 Pawel Krzywdzinski
//

import Foundation
import BinaryFlags


public protocol CustomByteCoderSize {
    var sizeForByteCoder: Int { get }
}

extension BinaryFlags : CustomByteCoderSize {
    public var sizeForByteCoder: Int {
        return MemoryLayout<Enum.RawValue>.size
    }
}

extension Dictionary : CustomByteCoderSize where Value : Encodable {
    public var sizeForByteCoder: Int {
        var size = 0
        for value in self.values {
            if let customValue = value as? CustomByteCoderSize {
                size += customValue.sizeForByteCoder
            } else {
                size += value.sizeForByteCoder
            }
        }
        return size
    }
}

extension Array : CustomByteCoderSize where Element : Encodable {
    public var sizeForByteCoder: Int {
        var size = 0
        for value in self {
            if let customValue = value as? CustomByteCoderSize {
                size += customValue.sizeForByteCoder
            } else {
                size += value.sizeForByteCoder
            }
        }
        return size
    }
}

extension String : CustomByteCoderSize {
    public var sizeForByteCoder: Int {
        return self.utf8.count + 1
    }
}


