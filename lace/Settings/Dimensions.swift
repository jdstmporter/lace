//
//  Dimensions.swift
//  lace
//
//  Created by Julian Porter on 22/04/2022.
//

import Foundation


class ViewPartDimensions : Sequence {
    
    static let PREFIX = "Dimensions-"
    
    typealias Container=[ViewPart:Double]
    typealias Iterator = Container.Iterator
    private var values : Container = [:]
    
    public required init() { self.update() }
    public required init(_ other : ViewPartDimensions) {
        other.forEach { kv in self.values[kv.key] = kv.value }
    }
    
    private func defaultValue(_ p : ViewPart) -> Double { 1.0 }
    private func key(_ p : ViewPart) -> String { "\(ViewPartDimensions.PREFIX)\(p)" }
    public func load(_ p : ViewPart) -> Double? { Defaults.double(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : Double) { Defaults.setDouble(forKey: key(p), value: v) }
    
    public subscript(_ p : ViewPart) -> Double {
        get { values[p] ?? defaultValue(p) }
        set { values[p] = newValue }
    }
    public func touch() {
        ViewPart.allCases.forEach { p in
            if let c=values[p] { values[p]=c }
        }
    }
    public func commit() {
        ViewPart.allCases.forEach { p in self.save(p,self[p]) }
    }
    public func update() {
        self.reset()
        ViewPart.allCases.forEach { p in
            if let v = self.load(p) { self[p]=v }
        }
    }
    public func has(_ p : ViewPart) -> Bool { values[p] != nil }
    public func makeIterator() -> Iterator { values.makeIterator() }
    public func reset() { self.values.removeAll() }
}

