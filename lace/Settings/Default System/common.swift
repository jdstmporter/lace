//
//  common.swift
//  lace
//
//  Created by Julian Porter on 10/09/2022.
//

import Foundation
import AppKit


extension Double : Nameable, HasDefault {
    public static func def(_ v : any DefaultPart) -> Double { 1 }
    public var str : String { description }
    public var name : String { str }
}

extension NSColor : Nameable, HasDefault {
    public static var zero : NSColor { .black }
    public static func def(_ v : any DefaultPart) -> NSColor {
        let vb : ViewPart = v as? ViewPart ?? .Background
        return (vb == .Background) ? .white.deviceRGB : .black.deviceRGB
    }
    public var str : String { rgba?.description ?? "[]" }
    public var name : String { str }
}
extension NSFont : Nameable, HasDefault {
    public static var zero : NSFont { NSFont.systemFont(ofSize: NSFont.systemFontSize) }
    public static func def(_ v : any DefaultPart) -> NSFont {
        let vf : FontPart = v as? FontPart ?? .Title
        var size = NSFont.systemFontSize
        switch vf {
        case .Title:
            size=NSFont.systemFontSize(for: .large)
        case .Metadata:
            break
        case .Comment:
            size=NSFont.smallSystemFontSize
        default:
            break
        }
        return NSFont.systemFont(ofSize: size)
    }
    public var str : String { components?.description ?? "[:]" }
    public var name : String { str }
}
extension URL : Nameable, HasDefault {
    public static var zero : URL { URL(".") }
    public static func def(_ : any DefaultPart) -> URL { zero }
    public var str : String { path }
    public var name : String { str }
}

extension Int: Nameable, HasDefault {
    public var str : String { description }
    public var name : String { str }
    public static func def(_ : any DefaultPart) -> Int { zero }
}
extension String : Nameable, HasDefault {
    public var str : String { self }
    public var name : String { str }
    public static func def(_ : any DefaultPart) -> String { zero }
}
extension Bool : Nameable, HasDefault {
    public var str : String { self ? "ON" : "OFF" }
    public var name : String { str }
    public static func def(_ : any DefaultPart) -> Bool { false }
}

extension Decimal : Nameable, HasDefault {
    public static var zero : Decimal { Decimal() }
    public static func def(_ : any DefaultPart) -> Decimal { zero }
    public var str : String {
        var val=self
        return NSDecimalString(&val, NSLocale.current)
    }
    public var name : String { str }
}



