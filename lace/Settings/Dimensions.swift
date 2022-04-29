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
    
    public required init() {}
    public required init(_ other : ViewPartDimensions) {
        other.forEach { kv in self.values[kv.key] = kv.value }
    }
    
    private func defaultValue(_ p : ViewPart) -> Double { 1.0 }
    public subscript(_ p : ViewPart) -> Double {
        get { values[p] ?? defaultValue(p) }
        set { values[p] = newValue }
    }
    public func touch() {
        ViewPart.allCases.forEach { p in
            if let c=values[p] { values[p]=c }
        }
    }
    public func saveDefault() throws {
        ViewPart.allCases.forEach { p in
            Defaults.setDouble(forKey: "\(ViewPartDimensions.PREFIX)\(p)", value: self[p])
        }
    }
    public func loadDefault() {
        self.values.removeAll()
        ViewPart.allCases.forEach { p in
            if let v = Defaults.double(forKey: "\(ViewPartDimensions.PREFIX)\(p)") { self[p]=v }
        }
    }
    public func has(_ p : ViewPart) -> Bool { values[p] != nil }
    public func makeIterator() -> Iterator { values.makeIterator() }
    public func reset() { self.values.removeAll() }
}

