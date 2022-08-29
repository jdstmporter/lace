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
    
    public init() { self.update() }
    
    public var colourSpace : CGColorSpace { CGColorSpaceCreateDeviceRGB() }
    
    private func defaultValue(_ p : ViewPart) -> NSColor {
        (p == .Background) ? ViewPartColours.White : ViewPartColours.Black
    }
    private func key(_ p : ViewPart) -> String { "\(ViewPartColours.PREFIX)\(p)" }
    public func load(_ p : ViewPart) throws -> NSColor  { try Defaults.colour(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : NSColor) throws { try Defaults.setColour(value: v,forKey:key(p)) }
    
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
    
    public func commit() throws {
        try ViewPart.allCases.forEach { p in try self.save(p, self[p]) }
    }
    public func update() {
        self.reset()
        ViewPart.allCases.forEach { p in
            do { self[p]=try self.load(p) }
            catch(let e) {
                syslog.error("Error loading: \(e) - reverting to default")
            }
        }
    }
}
