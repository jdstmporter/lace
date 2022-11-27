//
//  simple.swift
//  lace
//
//  Created by Julian Porter on 06/10/2022.
//

import Foundation
import AppKit



enum DataMode {
    case Defaults
    case Temp
}

protocol ViewData {
    associatedtype Element where Element : Decodable, Element : HasDefault
    typealias Container = [ViewPart:Element]
    
    var mode : DataMode { get set }
    var values : Container { get set }
    
    static var PREFIX : String { get }
    func key(_ : ViewPart) -> String
    
    
    init(_ mode : DataMode)
    subscript(_ p : ViewPart) -> Element { get set }
    mutating func revert()
    mutating func commit()
    
    func load(_ : ViewPart) -> Element?
    func save(_ : ViewPart,_ : Element)
    func adjustToSet(_ : Element) -> Element
    
}

extension ViewData {
    
    func key(_ p : ViewPart) -> String { "\(Self.PREFIX)\(p)" }
    
    func value(_ p : ViewPart) -> Element { self.load(p) ?? (Element.def(p) as! Self.Element) }
    subscript(_ p: ViewPart) -> Element {
        get {
            let v=self.value(p)
            return self.mode == .Defaults ? v : self.values[p] ?? v
        }
        set {
            let v=self.adjustToSet(newValue)
            self.values[p]=v
        }
    }
    mutating func revert() { self.values.removeAll() }
    mutating func commit() {
        guard self.mode == .Temp else { return }
        ViewPart.allCases.forEach { p in
            if let v = self.values[p] {
                self.save(p,v)
            }
        }
        self.revert()
    }
    
    func load(_ p : ViewPart) -> Element? { try? Defaults.read(key(p)) }
    func save(_ p : ViewPart,_ v : Element) { try? Defaults.write(key(p),v) }
    
    func adjustToSet(_ v: Element) -> Element { v }
}





class ViewDimensions : ViewData {
    typealias Element = Double
    static var PREFIX : String { "Dimensions-" }
    
    var mode: DataMode = .Defaults
    var values: Container = [ViewPart:Element]()
    
    required init(_ mode : DataMode) { self.mode=mode }
    
}



class ViewColours : ViewData {
    typealias Element = NSColor
    static var PREFIX : String { "Colours-" }
    
    var mode: DataMode = .Defaults
    var values: Container = [ViewPart:Element]()
    
    required init(_ mode : DataMode) { self.mode=mode }
    
    func adjustToSet(_ e: NSColor) -> NSColor { e.deviceRGB }
}

class ViewFonts : ViewData {
    typealias Element = NSFont

    static var PREFIX : String { "Fonts-" }
    
    var mode: DataMode = .Defaults
    var values: Container = [ViewPart:Element]()
    
    required init(_ mode : DataMode) { self.mode=mode }
}


class ViewDelegate {
    var colours : ViewColours
    var dimensions : ViewDimensions
    
    init(_ mode : DataMode = .Defaults) {
        colours=ViewColours(mode)
        dimensions=ViewDimensions(mode)
    }
    
    func set(_ row : ViewPart,_ colour : NSColor) { colours[row]=colour }
    func set(_ row : ViewPart,_ dim : Double) { dimensions[row]=dim }
    
    func revert() {
        self.colours.revert()
        self.dimensions.revert()
    }
    func commit() {
        self.colours.commit()
        self.dimensions.commit()
    }
    subscript(_ row : ViewPart) -> (colour: NSColor, dimension: Double) {
        (colour: self.colours[row], dimension: self.dimensions[row])
    }
    
    static var the : [DataMode : ViewDelegate] = [:]
    static func load(_ m : DataMode = .Defaults) -> ViewDelegate {
        if the[m]==nil { the[m]=ViewDelegate(m) }
        return the[m]!
    }
}

