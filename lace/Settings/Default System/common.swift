//
//  common.swift
//  lace
//
//  Created by Julian Porter on 10/09/2022.
//

import Foundation
import AppKit

protocol HasDefault {
    associatedtype V
    static var zero : V { get }
    static func def(_ : ViewPart) -> V
    
}

public protocol Nameable {
    var str : String { get }
}

extension UInt32 : Nameable, HasDefault {
    var hex : String { String(format: "%08x",self) }
    public var str : String { hex }
    static func def(_ : ViewPart) -> UInt32 { zero }
}

extension Int32 : Nameable, HasDefault {
    var hex : String { UInt32(truncatingIfNeeded: self).hex }
    public var str : String { hex }
    static func def(_ : ViewPart) -> Int32 { zero }
}
extension Double : Nameable, HasDefault {
    public static func def(_ v : ViewPart) -> Double { 1 }
    public var str : String { description }
}

extension NSColor : Nameable, HasDefault {
    public static var zero : NSColor { .black }
    public static func def(_ v : ViewPart) -> NSColor {
        (v == .Background) ? .white.deviceRGB : .black.deviceRGB
    }
    public var str : String { rgba?.description ?? "[]" }
}
extension NSFont : Nameable, HasDefault {
    public static var zero : NSFont { NSFont.systemFont(ofSize: NSFont.systemFontSize) }
    public static func def(_ v : ViewPart) -> NSFont {
        var size = NSFont.systemFontSize
        switch v {
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
}
extension URL : Nameable, HasDefault {
    public static var zero : URL { URL(".") }
    public static func def(_ : ViewPart) -> URL { zero }
    public var str : String { path }
}



extension Int: Nameable, HasDefault {
    public var str : String { description }
    public static func def(_ : ViewPart) -> Int { zero }
}
extension String : Nameable, HasDefault {
    public var str : String { self }
    public static func def(_ : ViewPart) -> String { zero }
}
extension Bool : Nameable, HasDefault {
    public var str : String { self ? "ON" : "OFF" }
    public static func def(_ : ViewPart) -> Bool { false }
}

public protocol NameableEnumeration : CaseIterable, Hashable, Nameable, Decodable {
    init?(_ : String)
}

extension NameableEnumeration {
    public init?(_ name : String) {
        if let item = (Self.allCases.first { $0.str==name }) { self=item }
        else { return nil }
    }
    public var str : String { "\(self)" }
    
    public static func dec(x: Any) -> Self? {
        guard let name = x as? String else { return nil }
        return Self(name)
    }
    public func enc() -> Any? {
        self.str
    }
}
    
