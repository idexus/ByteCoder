//
//  EncodableExtension.swift
//  ByteCoder
//
//  Created by Pawel Krzywdzinski on 23/10/2018.
//  Copyright (c) 2018 Pawel Krzywdzinski
//

import Foundation


extension Encodable {
    
    public var sizeForByteCoder: Int {
        
        var selfMirror: Mirror! = Mirror(reflecting: self)
        var size = 0
        
        while selfMirror != nil {
            if selfMirror.children.count > 0 {
                for child in selfMirror.children {
                    switch child {
                    case let ( _ , value as CustomByteCoderSize):   // first if CustomByteCoderSize
                        size += value.sizeForByteCoder
                    case let ( _ , value as Codable):
                        size += value.sizeForByteCoder
                    default:
                        break
                    }
                }
            }
            // now go to superclass of current `selfMirror`
            selfMirror = selfMirror.superclassMirror
        }
        if size > 0 { return size }
        
        return MemoryLayout<Self>.size
    }
}
