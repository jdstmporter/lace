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

/*

protocol P {
    associatedtype Element
    
    static var PREFIX : String { get }
    typealias Container = [ViewPart:Element]
    
    var values : Container { get set }
    
    
    func key(_ : ViewPart) -> String
    func has(_ : ViewPart) -> Bool
    func load(_ : ViewPart) -> Element?
    //func save(_ : ViewPart,_ : Element)
    
    static func defaultValue(_ : ViewPart) -> Element
    
    mutating func copy<O>(_ other : O)
    where O: P, O.Element==Self.Element
    
    mutating func reset()
    mutating func reload()
    //mutating func commit()
    
    func value(_ : ViewPart) -> Element
    func adjustToSet(_ e : Element) -> Element
    subscript(_ : ViewPart) -> Element { get }
}

extension P {
    func key(_ p : ViewPart) -> String { "\(Self.PREFIX)\(p)" }
    func has(_ p : ViewPart) -> Bool { values[p] != nil }
    
    mutating func copy<O>(_ other : O)
    where O: P, O.Element==Self.Element
    {
        self.reset()
        ViewPart.allCases.forEach { p in self.values[p]=other[p] }
    }
    
    mutating func reset() { self.values.removeAll() }
    mutating func reload() {
        self.reset()
        ViewPart.allCases.forEach { p in
            if let v = self.load(p) { self.values[p]=v }
        }
    }
    
    func value(_ p : ViewPart) -> Element { self.values[p] ?? Self.defaultValue(p) }
    subscript(_ p: ViewPart) -> Element { self.value(p) }
            
}


protocol PMutable : P {

    var temps : Container { get set }
    
    func save(_ : ViewPart,_ : Element)
    
    mutating func revert()
    mutating func commit()
    

    func adjustToSet(_ e : Element) -> Element
    subscript(_ : ViewPart) -> Element { get set }
}

extension PMutable {
    
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
    
    subscript(_ p: ViewPart) -> Element {
        get { self.temps[p] ?? self.value(p) }
        set {
            let v=self.adjustToSet(newValue)
            self.temps[p]=v
        }
    }
}

*/



