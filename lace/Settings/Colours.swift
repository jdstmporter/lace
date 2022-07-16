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

class ViewPartColours : Sequence {
    static let PREFIX = "Colours-"
    
    typealias Container=[ViewPart:NSColor]
    typealias Iterator = Container.Iterator
    private var values : Container = [:]
    
    static var White : NSColor { .white.deviceRGB }
    static var Black : NSColor { .black.deviceRGB }
    
    public init() {}
    public init(_ other : ViewPartColours) {
        other.forEach { kv in self.values[kv.key] = kv.value }
    }
    
    public var colourSpace : CGColorSpace { CGColorSpaceCreateDeviceRGB() }
    
    public static func defaults() -> ViewPartColours {
        let c=ViewPartColours()
        c.loadDefault()
        return c
    }
    
    private func defaultValue(_ p : ViewPart) -> NSColor {
        (p == .Background) ? ViewPartColours.White : ViewPartColours.Black
    }
    
    public subscript(_ p : ViewPart) -> NSColor {
        get { values[p] ?? defaultValue(p) }
        set { values[p] = newValue.deviceRGB }
    }
    public subscript(cg: ViewPart) -> CGColor { self[cg].cgColor }
    
    public func has(_ p : ViewPart) -> Bool { values[p] != nil }
    func makeIterator() -> Iterator { values.makeIterator() }
    
    public func touch() {
        ViewPart.allCases.forEach { p in
            if let c=values[p]?.deviceRGB { values[p]=c }
        }
    }
    public func reset() {
        self.values.removeAll()
    }
    
    public func saveDefault() throws {
        try ViewPart.allCases.forEach { p in
            try Defaults.setColour(value: self[p], forKey: "\(ViewPartColours.PREFIX)\(p)")
        }
    }
    public func loadDefault() {
        self.values.removeAll()
        ViewPart.allCases.forEach { p in
            do { self[p]=try Defaults.colour(forKey: "\(ViewPartColours.PREFIX)\(p)") }
            catch(let e) {
                syslog.error("Error loading: \(e) - reverting to default")
            }
        }
    }
}
