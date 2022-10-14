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

extension Double : HasDefault { }

/*

class ViewDimensions : P {
    static let PREFIX = "Dimensions-"
    typealias Element = Double
    
    var values : Container = [:]

    public func load(_ p : ViewPart) -> Element?  { Defaults.double(forKey: key(p))}
    
    
    required init() {
        ViewPart.allCases.forEach { p in
            if let v = self.load(p) { self.values[p]=v }
        }
    }
    func adjustToSet(_ e: Double) -> Double { e }
    
    static func defaultValue(_ p : ViewPart) -> Element { 1.0 }
}

class ViewDimensionsMutable : PMutable {
    
    static let PREFIX = "Dimensions-"
    typealias Element = Double
    
    var values : Container = [:]
    var temps : Container = [:]
    
    public func load(_ p : ViewPart) -> Element?  { Defaults.double(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : Element) { Defaults.setDouble(forKey:key(p), value: v) }
    
    required init() {
        ViewPart.allCases.forEach { p in
            if let v = self.load(p) { self.values[p]=v }
        }
    }
    func adjustToSet(_ e: Double) -> Double { e }
    
    static func defaultValue(_ p : ViewPart) -> Element { 1.0 }
}

*/
