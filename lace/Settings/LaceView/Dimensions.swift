//
//  Dimensions.swift
//  lace
//
//  Created by Julian Porter on 22/04/2022.
//

import Foundation



extension Dictionary {
    mutating func merge(_ other : Dictionary<Self.Key,Self.Value>) {
        other.forEach { kv in self[kv.key]=kv.value }
    }
}

extension Double : HasDefault { }


class ViewDimensions : P {
    
    static let PREFIX = "Dimensions-"
    typealias Element = Double
    
    var values : Container = [:]
    var temps : Container = [:]
    var mode : LaceViewMode = .Permanent
    
    public func load(_ p : ViewPart) -> Element?  { Defaults.double(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : Element) { Defaults.setDouble(forKey:key(p), value: v) }
    
    required init(mode: LaceViewMode) {
        self.mode=mode
        ViewPart.allCases.forEach { p in
            if let v = self.load(p) { self.values[p]=v }
        }
    }
    convenience init() { self.init(mode: .Permanent) }
    func adjustToSet(_ e: Double) -> Double { e }
    
    static func defaultValue(_ p : ViewPart) -> Element { 1.0 }
}

