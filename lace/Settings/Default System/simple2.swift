//
//  simple2.swift
//  lace
//
//  Created by Julian Porter on 10/12/2022.
//

import Foundation
import AppKit

protocol BaseData2 {
    
}


protocol ViewData2 {
    associatedtype Element where Element : EncDec, Element : HasDefault
    typealias Container = [ViewPart:Element]
    
    var values : Container { get set }
    
    static var PREFIX : DefaultKind { get }
    
    
    
    init()
    subscript(_ p : ViewPart) -> Element { get set }
    mutating func revert()
    mutating func commit()
    
    func get(_ : ViewPart) -> Element
    mutating func set(_ : ViewPart,_  : Element)
    func load(_ : ViewPart) -> Element?
    func save(_ : ViewPart,_ : Element)
    func adjustToSet(_ : Element) -> Element
    
    func has(_ : ViewPart) -> Bool
    
}

extension ViewData2 {
    
    func value(_ p : ViewPart) -> Element { self.load(p) ?? (Element.def(p) as! Self.Element) }
    subscript(_ p: ViewPart) -> Element {
        get {
            //let v=self.value(p)
            return self.values[p] ?? self.value(p)
        }
        set {
            let v=self.adjustToSet(newValue)
            self.values[p]=v
        }
    }
    func get(_ p : ViewPart) -> Element { self[p] }
    mutating func set(_ p : ViewPart,_ e : Element) { self[p]=e }
    
    mutating func revert() { self.values.removeAll() }
    mutating func commit() {
        ViewPart.allCases.forEach { p in
            if let v = self.values[p] {
                self.save(p,v)
            }
        }
        self.revert()
    }
    
    func load(_ p : ViewPart) -> Element? { Defaults.GetPart(kind:Self.PREFIX,part: p) }
    func save(_ p : ViewPart,_ v : Element) { Defaults.SetPart(kind:Self.PREFIX,part: p,value: v) }
    func del(_ p : ViewPart) { Defaults.RemovePart(kind: Self.PREFIX, part: p) }
    
    func readAndClear(_ p : ViewPart) -> Element? {
        let v = load(p)
        del(p)
        return v
    }
    
    func adjustToSet(_ v: Element) -> Element { v }
    
    func has(_ p : ViewPart) -> Bool { load(p) != nil }
    
}

class ViewDimensions : ViewData2 {
    typealias Element = Double
    static var PREFIX = DefaultKind.Dimension
    
    var values: Container = [ViewPart:Element]()
    
    required init() {}
    
}

class ViewColours : ViewData2 {
    typealias Element = NSColor
    static var PREFIX = DefaultKind.Colour
    
    var values: Container = [ViewPart:Element]()
    
    required init() { }
    
    func adjustToSet(_ e: NSColor) -> NSColor { e.deviceRGB }
}

class ViewFonts : ViewData2 {
    typealias Element = NSFont
    static var PREFIX = DefaultKind.Font
    
    
    var values: Container = [ViewPart:Element]()
    
    required init() {  }
}

class ViewPaths : ViewData2 {
    typealias Element = URL
    static var PREFIX = DefaultKind.URL
    
    var values: Container = [ViewPart:Element]()
    
    required init() {  }
    
    
   
}
