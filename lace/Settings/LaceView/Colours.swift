//
//  Colours.swift
//  lace
//
//  Created by Julian Porter on 18/04/2022.
//

import Foundation
import AppKit
import CoreGraphics

typealias Serialised = [String : Any]

protocol Parameter {
    associatedtype V
    var serialised : Serialised? { get }
    static func load(_ : Serialised) -> V?
}

extension NSColor  {
    
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
extension NSColor : Parameter {
    static func load(_ p : Serialised) -> NSColor? {
        guard let rgba=p["rgba"] as? [CGFloat] else { return nil }
        return NSColor(rgba)
    }
    var serialised: Serialised? {
        guard let rgba = self.rgba else { return nil}
        return ["rgba" : rgba]
    }
    
    
}
extension NSColor : HasDefault {
    public static var zero : NSColor { .black }
    public static func def(_ v : ViewPart) -> NSColor {
        (v == .Background) ? .white.deviceRGB : .black.deviceRGB
    }
}

extension NSFont : HasDefault {
    public static var zero : NSFont { NSFont.systemFont(ofSize: NSFont.systemFontSize) }
    public static func def(_ v : ViewPart) -> NSFont {
        var size = NSFont.systemFontSize
        switch v {
        case .Title:
            size+=2
        case .Metadata:
            break
        case .Comment:
            size=NSFont.smallSystemFontSize
        default:
            break
        }
        return NSFont.systemFont(ofSize: size)
    }
}

extension NSFont {
    convenience init?(components c: [String:Any]) {
        guard let name : String = c["name"] as? String, let size : CGFloat = c["size"] as? CGFloat else { return nil }
        self.init(name: name, size: size)
    }
    var components : [String:Any]? {
        var out : [String:Any] = [:]
        let attributes = self.fontDescriptor.fontAttributes
        guard let name = attributes[.name], let size = attributes[.size] else { return nil }
        out["name"] = name
        out["size"] = size
        return out
    }
}


extension NSFont : Parameter {
    
    var serialised : Serialised? { self.components }

    static func load(_ s: Serialised) -> NSFont? { NSFont(components: s) }
}

extension Double : Parameter {
    var serialised : Serialised? { ["value" : self] }
    static func load(_ s : Serialised) -> Double? {
        guard let v=s["value"] as? Double else { return nil }
        return v
    }
}
extension String : Parameter {
    var serialised : Serialised? { ["value" : self] }
    static func load(_ s : Serialised) -> String? {
        guard let v=s["value"] as? String else { return nil }
        return v
    }
}


