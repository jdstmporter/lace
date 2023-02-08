//
//  decodable.swift
//  lace
//
//  Created by Julian Porter on 26/11/2022.
//

import Foundation
import AppKit




extension Int : EncDec {
    public func enc() -> Any? { self as Any }
    public static func dec(_ x: Any) -> Int? {
        guard let m=x as? Self else { return nil }
        return m
    }
}
extension Bool : EncDec {
    public func enc() -> Any? { self as Any }
    public static func dec(_ x: Any) -> Bool? {
        guard let m=x as? Self else { return nil }
        return m
    }
}
extension Double : EncDec {
    public func enc() -> Any? { self as Any }
    public static func dec(_ x: Any) -> Double? {
        guard let m=x as? Self else { return nil }
        return m
    }
}
extension String : EncDec {
    public func enc() -> Any? { self as Any }
    public static func dec(_ x: Any) -> String? {
        guard let m=x as? Self else { return nil }
        return m
    }
}

extension NSColor : EncDec {
    public static func dec(_ x: Any) -> Self? {
        guard let components = x as? [CGFloat] else { return nil }
        guard components.count==4 else { return nil }
        return (NSColor(components) as! Self)
    }
    public func enc() -> Any? {
        guard let components = self.rgba, components.count==4 else { return nil }
        return components
    }
}

extension NSFont : EncDec {
    public static func dec(_ x: Any) -> Self? {
        guard let info = x as? [String:Any] else { return nil }
        guard let f = NSFont(components: info) else { return nil }
        return (f as! Self)
    }
    public func enc() -> Any? {
        self.components
    }
}

extension URL : EncDec {
    public static func dec(_ x: Any) -> URL? {
        syslog.announce("raw is [\(x)]")
        guard let path = x as? String else { return nil }
        syslog.announce("string is [\(path)]")
        return URL(path)
    }
    public func enc() -> Any? {
        self.path as Any
    }
}

extension Decimal : EncDec {
    public static func dec(_ x: Any) -> Decimal? {
        guard let val = x as? String else { return nil }
        return Decimal(val)
    }
    public func enc() -> Any? {
        self.str
    }
}

extension Pricking : EncDec {
    
    static func dec(_ d: Any) -> Pricking? {
        guard let data=d as? Data else { return nil }
        return try? JSONDecoder().decode(Pricking.self, from: data)
    }
    
    func enc() -> Any? {
        try? JSONEncoder().encode(self)
    }
}


func dec<T>(_ x : Any) -> T? where T : EncDec { T.dec(x) }
func enc<T>(_ v : T) -> Any? where T : EncDec { v.enc() }


