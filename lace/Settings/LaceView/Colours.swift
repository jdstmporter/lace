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

/*class ViewColours : P {
    static let PREFIX = "Colours-"
    typealias Element = NSColor
    
    var values : Container = [:]
    
    public func load(_ p : ViewPart) -> Element?  { try? Defaults.colour(forKey: key(p))}
    func adjustToSet(_ e: NSColor) -> NSColor { e.deviceRGB }
    
    init() {
        ViewPart.allCases.forEach { p in
            if let v = self.load(p) { self.values[p]=self.adjustToSet(v) }
        }
    }
    static func defaultValue(_ p : ViewPart) -> Element {
        (p == .Background) ? .white.deviceRGB : .black.deviceRGB
    }
    public static var colourSpace : CGColorSpace { CGColorSpaceCreateDeviceRGB() }
}

class ViewColoursMutable : PMutable {
    
    static let PREFIX = "Colours-"
    typealias Element = NSColor
    
    var values : Container = [:]
    var temps : Container = [:]
    
    public func load(_ p : ViewPart) -> Element?  { try? Defaults.colour(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : Element) { try? Defaults.setColour(value: v,forKey:key(p)) }
    
    init() {
        ViewPart.allCases.forEach { p in
            if let v = self.load(p) { self.values[p]=self.adjustToSet(v) }
        }
    }
    
    func adjustToSet(_ e: NSColor) -> NSColor { e.deviceRGB }

    static func defaultValue(_ p : ViewPart) -> Element {
        (p == .Background) ? .white.deviceRGB : .black.deviceRGB
    }
    public static var colourSpace : CGColorSpace { CGColorSpaceCreateDeviceRGB() }
}
 */

