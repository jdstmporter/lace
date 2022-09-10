//
//  common.swift
//  lace
//
//  Created by Julian Porter on 10/09/2022.
//

import Foundation

protocol HasDefault {
    associatedtype V
    static var zero : V { get }
}

protocol P {
    associatedtype Element
    
    static var PREFIX : String { get }
    typealias Container = [ViewPart:Element]
    
    var values : Container { get set }
    var temps : Container { get set }
    var mode : LaceViewMode { get set }
    
    func key(_ : ViewPart) -> String
    func has(_ : ViewPart) -> Bool
    func load(_ : ViewPart) -> Element?
    func save(_ : ViewPart,_ : Element)
    
    static func defaultValue(_ : ViewPart) -> Element
    
    init(mode: LaceViewMode)
    
    mutating func reset()
    mutating func reload()
    mutating func revert()
    mutating func commit()
    
    func value(_ : ViewPart) -> Element
    func adjustToSet(_ e : Element) -> Element
    subscript(_ : ViewPart) -> Element { get set }
}

extension P {
    func key(_ p : ViewPart) -> String { "\(Self.PREFIX)\(p)" }
    func has(_ p : ViewPart) -> Bool { values[p] != nil }
    
    mutating func reset() {
        self.values.removeAll()
        self.temps.removeAll()
    }
    mutating func reload() {
        self.reset()
        ViewPart.allCases.forEach { p in
            if let v = self.load(p) { self.values[p]=v }
        }
    }
    mutating func revert() { self.temps.removeAll() }
    mutating func commit() {
        self.values.merge(self.temps)
        ViewPart.allCases.forEach { p in
            if let v = self.temps[p] {
                self.values[p]=v
                self.save(p,v)
            }
        }
        self.revert()
    }
    
    func value(_ p : ViewPart) -> Element { self.values[p] ?? Self.defaultValue(p) }
    
    subscript(_ p: ViewPart) -> Element {
        get {
            switch self.mode {
            case .Permanent:
                return self.value(p)
            case .Temporary:
                return self.temps[p] ?? self.value(p)
            }
        }
        set {
            let v=self.adjustToSet(newValue)
            switch self.mode {
            case .Permanent:
                self.values[p]=v
            case .Temporary:
                self.temps[p]=v
            }
        }
    }
}





