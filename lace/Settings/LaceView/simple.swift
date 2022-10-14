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
    associatedtype Element
    typealias Container = [ViewPart:Element]
    
    static var PREFIX : String { get }
    func key(_ : ViewPart) -> String
    
    var mode : DataMode { get }
    var values : Container { get set }
    
    func load(_ : ViewPart) -> Element?
    func save(_ : ViewPart,_ : Element)
    
    func adjustToSet(_ : Element) -> Element
    
    static func defaultValue(_ : ViewPart) -> Element
    func value(_ : ViewPart) -> Element
    subscript(_ : ViewPart) -> Element { get set }
    
    mutating func revert()
    mutating func commit()
    
    
}

extension ViewData {
    func key(_ p : ViewPart) -> String { "\(Self.PREFIX)\(p)" }
    func value(_ p : ViewPart) -> Element {
         self.load(p) ?? Self.defaultValue(p)
    }
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
    
    
}



class ViewDimensions : ViewData {
    static let PREFIX = "Dimensions-"
    typealias Element = Double
    
    
    var values : Container = [:]
    let mode : DataMode
    
    init(_ mode : DataMode = .Defaults) { self.mode=mode }
    
    static func defaultValue(_ p : ViewPart) -> Element { 1.0 }
    public func load(_ p : ViewPart) -> Element?  { Defaults.double(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : Element) { Defaults.setDouble(forKey:key(p), value: v) }
    
    public func adjustToSet(_ v : Double) -> Double { v }
    
}



class ViewColours : ViewData {
    static let PREFIX = "Colours-"
    typealias Element = NSColor
    
    var values : Container = [:]
    let mode : DataMode
    
    init(_ mode : DataMode = .Defaults) { self.mode=mode }
    
    static func defaultValue(_ p : ViewPart) -> Element { (p == .Background) ? .white.deviceRGB : .black.deviceRGB }
    public func load(_ p : ViewPart) -> Element?  { try? Defaults.colour(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : Element) { try? Defaults.setColour(value: v,forKey:key(p)) }
    
    func adjustToSet(_ e: NSColor) -> NSColor { e.deviceRGB }
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

