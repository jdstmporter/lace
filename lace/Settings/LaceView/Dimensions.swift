//
//  Dimensions.swift
//  lace
//
//  Created by Julian Porter on 22/04/2022.
//

import Foundation
import AppKit



extension Dictionary {
    mutating func merge(_ other : Dictionary<Self.Key,Self.Value>) {
        other.forEach { kv in self[kv.key]=kv.value }
    }
}


extension Double : HasDefault {
    public static func def(_ v : ViewPart) -> Double { 1 }
}

