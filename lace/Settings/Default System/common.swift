//
//  common.swift
//  lace
//
//  Created by Julian Porter on 10/09/2022.
//

import Foundation

protocol HasDefault {
    associatedtype V
    static var zero : V { get }
    static func def(_ : ViewPart) -> V
}

public protocol Nameable {
    var str : String { get }
}

extension UInt32 : Nameable {
    var hex : String { String(format: "%08x",self) }
    public var str : String { hex }
}

extension Int32 : Nameable {
    var hex : String { UInt32(truncatingIfNeeded: self).hex }
    public var str : String { hex }
}

extension Int: Nameable { public var str : String { "\(self)" }}
extension String : Nameable { public var str : String { self } }
extension Bool : Nameable { public var str : String { self ? "ON" : "OFF" } }

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
    
