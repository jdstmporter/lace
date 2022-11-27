//
//  decodable.swift
//  lace
//
//  Created by Julian Porter on 26/11/2022.
//

import Foundation
import AppKit

protocol Decodable {
    static func dec(_ : Any) -> Self?
    func enc() -> Any?
}
extension Decodable {
    func enc() -> Any? { self as Any }
    
    static func dec(_ x: Any) -> Self? {
        guard let m=x as? Self else { return nil }
        return m
    }
}

extension Int : Decodable {}
extension Bool : Decodable {}
extension Double : Decodable {}
extension String : Decodable {}

extension NSColor : Decodable {
    static func dec(x: Any) -> NSColor? {
        guard let components = x as? [CGFloat] else { return nil }
        guard components.count==4 else { return nil }
        return NSColor(components)
    }
    func enc() -> Any? {
        guard let components = self.rgba, components.count==4 else { return nil }
        return components
    }
}

extension NSFont : Decodable {
    static func dec(x: Any) -> NSFont? {
        guard let info = x as? [String:Any] else { return nil }
        guard let f = NSFont(components: info) else { return nil }
        return f
    }
    func enc() -> Any? {
        self.components
    }
}

func dec<T>(_ x : Any) -> T? where T : Decodable { T.dec(x) }
func enc<T>(_ v : T) -> Any? where T : Decodable { v.enc() }


