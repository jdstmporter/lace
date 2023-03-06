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
    associatedtype PartKey where PartKey : DefaultPart
    typealias Container = [PartKey:Element]
    
    var values : Container { get set }
    
    static var PREFIX : DefaultKind { get }
    
    
    
    init()
    subscript(_ p : PartKey) -> Element { get set }
    mutating func revert()
    mutating func commit()
    
    func get(_ : PartKey) -> Element
    mutating func set(_ : PartKey,_  : Element)
    func load(_ : PartKey) -> Element?
    func save(_ : PartKey,_ : Element)
    func adjustToSet(_ : Element) -> Element
    
    func has(_ : PartKey) -> Bool
    
}

extension ViewData2 {
    
    func value(_ p : PartKey) -> Element { self.load(p) ?? (Element.def(p) as! Self.Element) }
    subscript(_ p: PartKey) -> Element {
        get {
            //let v=self.value(p)
            let v = self.values[p] ?? self.value(p)
            syslog.announce("GET Key is \(p), value is \(v)")
            syslog.announce("VALUES is \(self.values)")
            return v
        }
        set {
            let v=self.adjustToSet(newValue)
            syslog.announce("SET Key is \(p), value is \(v)")
            self.values[p]=v
            syslog.announce("VALUES is \(self.values)")
            
        }
    }
    func get(_ p : PartKey) -> Element { self[p] }
    mutating func set(_ p : PartKey,_ e : Element) { self[p]=e }
    
    mutating func revert() { self.values.removeAll() }
    mutating func commit() {
        PartKey.allCases.forEach { p in
            if let v = self.values[p] {
                self.save(p,v)
            }
        }
        self.revert()
    }
    
    func load(_ p : PartKey) -> Element? { Defaults.GetPart(kind:Self.PREFIX,part: p) }
    func save(_ p : PartKey,_ v : Element) { Defaults.SetPart(kind:Self.PREFIX,part: p,value: v) }
    func del(_ p : PartKey) { Defaults.RemovePart(kind: Self.PREFIX, part: p) }
    
    func readAndClear(_ p : PartKey) -> Element? {
        let v = load(p)
        del(p)
        return v
    }
    
    func adjustToSet(_ v: Element) -> Element { v }
    
    func has(_ p : PartKey) -> Bool { load(p) != nil }
    
}

class ViewDimensions : ViewData2 {
    typealias Element = Double
    typealias PartKey = ViewPart
    static var PREFIX = DefaultKind.Dimension
    
    var values: Container = [ViewPart:Element]()
    
    required init() {}
    
}

class ViewColours : ViewData2 {
    typealias Element = NSColor
    typealias PartKey = ViewPart
    static var PREFIX = DefaultKind.Colour
    
    var values: Container = [ViewPart:Element]()
    
    required init() { }
    
    func adjustToSet(_ e: NSColor) -> NSColor { e.deviceRGB }
}

class ViewFonts : ViewData2 {
    
    typealias Element = NSFont
    typealias PartKey = FontPart
    static var PREFIX = DefaultKind.Font
    
    var values: Container = [FontPart:Element]()
    
    required init() {  }
}

class ViewPaths : ViewData2 {
    typealias Element = URL
    typealias PartKey = PathPart
    static var PREFIX = DefaultKind.URL
    
    var values: Container = [PathPart:Element]()
    
    required init() {  }
}

class ViewLace : ViewData2 {
    typealias Element = Int
    typealias PartKey = ThreadPart
    static var PREFIX = DefaultKind.Threads
    
    var values : Container = [ThreadPart:Element]()
    
    required init() {}

}

