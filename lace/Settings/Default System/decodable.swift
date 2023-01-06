//
//  decodable.swift
//  lace
//
//  Created by Julian Porter on 26/11/2022.
//

import Foundation
import AppKit




extension Int : EncDec {} 
extension Bool : EncDec {}
extension Double : EncDec {}
extension String : EncDec {}

extension NSColor : EncDec {
    public static func dec(x: Any) -> NSColor? {
        guard let components = x as? [CGFloat] else { return nil }
        guard components.count==4 else { return nil }
        return NSColor(components)
    }
    public func enc() -> Any? {
        guard let components = self.rgba, components.count==4 else { return nil }
        return components
    }
}

extension NSFont : EncDec {
    public static func dec(x: Any) -> NSFont? {
        guard let info = x as? [String:Any] else { return nil }
        guard let f = NSFont(components: info) else { return nil }
        return f
    }
    public func enc() -> Any? {
        self.components
    }
}

extension URL : EncDec {
    public static func dec(x: Any) -> URL? {
        guard let path = x as? String else { return nil }
        return URL(path)
    }
    public func enc() -> Any? {
        self.relativePath
    }
}

extension Decimal : EncDec {
    public static func dec(x: Any) -> Decimal? {
        guard let val = x as? String else { return nil }
        return Decimal(val)
    }
    public func enc() -> Any? {
        self.str
    }
}


func dec<T>(_ x : Any) -> T? where T : EncDec { T.dec(x) }
func enc<T>(_ v : T) -> Any? where T : EncDec { v.enc() }


