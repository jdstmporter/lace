//
//  Colours.swift
//  lace
//
//  Created by Julian Porter on 18/04/2022.
//

import Foundation
import AppKit



extension NSColor {
    
    var sRGB : NSColor { self.usingColorSpace(.sRGB) ?? self }
    var calibratedRGB : NSColor { self.usingColorSpace(.genericRGB) ?? self }
    
    var rgba : [CGFloat]? {
        guard let c = self.usingColorSpace(.genericRGB) else { return nil }
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
        self.init(colorSpace: .genericRGB,components: c,count: c.count )
    }
    
    
}



class ViewPartColours : Sequence {
    typealias Container=[ViewPart:NSColor]
    typealias Iterator = Container.Iterator
    private var values : Container = [:]
    
    public init() {}
    public init(_ other : ViewPartColours) {
        other.forEach { kv in self.values[kv.key] = kv.value }
    }
    
    public static func defaults(prefix : String = "Colours-") -> ViewPartColours {
        let c=ViewPartColours()
        c.loadDefault(prefix: prefix)
        return c
    }
    
    private func defaultValue(_ p : ViewPart) -> NSColor {
        (p == .Background) ? .white : .black
    }
    
    public subscript(_ p : ViewPart) -> NSColor {
        get { values[p] ?? defaultValue(p) }
        set { values[p] = newValue.calibratedRGB }
    }
    public func has(_ p : ViewPart) -> Bool { values[p] != nil }
    func makeIterator() -> Iterator { values.makeIterator() }
    
    public func touch() {
        ViewPart.allCases.forEach { p in
            if let c=values[p]?.calibratedRGB { values[p]=c }
        }
    }
    public func reset() {
        self.values.removeAll()
    }
    
    public func saveDefault(prefix : String = "Colours-") throws {
        let d=Defaults()
        try ViewPart.allCases.forEach { p in
            try d.setColour(value: self[p], forKey: "\(prefix)\(p)")
        }
    }
    public func loadDefault(prefix : String = "Colours-") {
        self.values.removeAll()
        let d=Defaults()
        ViewPart.allCases.forEach { p in
            do { self[p]=try d.colour(forKey: "\(prefix)\(p)") }
            catch(let e) {
                print("Error loading: \(e) - reverting to default")
            }
        }
    }
}
