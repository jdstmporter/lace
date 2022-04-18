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
    
    var rgba : [CGFloat] {
        guard let c = self.usingColorSpace(.genericRGB) else { return [] }
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
    public typealias Container = [ViewPart:NSColor]
    public typealias Element = Container.Element
    public typealias Iterator = Container.Iterator
    
    
    private var colours : Container = [:]
    
    public init() {}
    
    private func defaultColour(_ p : ViewPart) -> NSColor {
        (p == .Background) ? .white : .black
    }
    
    public subscript(_ p : ViewPart) -> NSColor {
        get { colours[p] ?? defaultColour(p) }
        set { colours[p] = newValue.calibratedRGB }
    }
    public func has(_ p : ViewPart) -> Bool { colours[p] != nil }
    func makeIterator() -> Iterator { colours.makeIterator() }
    
    public func touch() {
        ViewPart.allCases.forEach { p in
            if let c=colours[p]?.calibratedRGB { colours[p]=c }
        }
    }
}
