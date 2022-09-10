//
//  Colours.swift
//  lace
//
//  Created by Julian Porter on 18/04/2022.
//

import Foundation
import AppKit
import CoreGraphics



extension NSColor {
    
    var sRGB : NSColor { self.usingColorSpace(.sRGB) ?? self }
    var genericRGB : NSColor { self.usingColorSpace(.genericRGB) ?? self }
    var deviceRGB : NSColor { self.usingColorSpace(.deviceRGB) ?? self }
    
    var rgba : [CGFloat]? {
        guard let c = self.usingColorSpace(.deviceRGB) else { return nil }
        let n=c.numberOfComponents
        var a=Array<CGFloat>.init(repeating: 0, count: n)
        a.withUnsafeMutableBufferPointer { p in
            if let b = p.baseAddress {
                c.getComponents(b)
            }
        }
        return a
        
    }
    convenience init(_ c: [CGFloat]) {
        self.init(colorSpace: .deviceRGB,components: c,count: c.count )
    }
    
    
}

extension NSColor : HasDefault { public static var zero : NSColor { .black }}


class ViewColours : P {
    
    static let PREFIX = "Colours-"
    typealias Element = NSColor
    
    var values : Container = [:]
    var temps : Container = [:]
    var mode : LaceViewMode = .Permanent
    
    public func load(_ p : ViewPart) -> Element?  { try? Defaults.colour(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : Element) { try? Defaults.setColour(value: v,forKey:key(p)) }
    
    
    
    required init(mode: LaceViewMode) {
        self.mode=mode
        ViewPart.allCases.forEach { p in
            if let v = self.load(p) { self.values[p]=self.adjustToSet(v) }
        }
    }
    convenience init() { self.init(mode: .Permanent) }
    
    func adjustToSet(_ e: NSColor) -> NSColor { e.deviceRGB }

    static func defaultValue(_ p : ViewPart) -> Element {
        (p == .Background) ? .white.deviceRGB : .black.deviceRGB
    }
    public static var colourSpace : CGColorSpace { CGColorSpaceCreateDeviceRGB() }
}

class PartAttributes {
    
    private var colours : ViewColours
    private var dimensions : ViewDimensions
    
    func reset() { colours.reset() ; dimensions.reset() }
    func reload() { colours.reload() ; dimensions.reload() }
    func revert() { colours.revert() ; dimensions.revert() }
    func commit() { colours.commit() ; dimensions.commit() }
    
    init(mode: LaceViewMode) {
        self.colours=ViewColours(mode: mode)
        self.dimensions=ViewDimensions(mode: mode)
    }
    
    subscript(colour p: ViewPart) -> NSColor { get { self.colours[p] } set { self.colours[p]=newValue } }
    subscript(dimension p: ViewPart) -> Double { get { self.dimensions[p] } set {  self.dimensions[p]=newValue } }
    
}

