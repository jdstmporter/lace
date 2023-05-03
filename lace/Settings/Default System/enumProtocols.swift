//
//  enumProtocols.swift
//  lace
//
//  Created by Julian Porter on 01/01/2023.
//

import Foundation

public protocol Nameable {
    var str : String { get }
    var name : String { get }
}

public protocol Defaultable {
    static var zero : Self { get }
}




public protocol DefaultPart : RawRepresentable, CaseIterable, Hashable, Nameable {
    init?(_ str : String)
}

extension DefaultPart {
    public var str : String { "\(self)" }
    public var name : String { str }
    
     public init?(_ str : String) {
         guard let x = (Self.allCases.first { $0.str == str }) else { return nil }
         self=x
    }
}

protocol HasDefault {
    associatedtype V
    static var zero : V { get }
    static func def(_ : any DefaultPart) -> V
}

/// Protocols for encoding and decoding to defaults
    


public protocol EncDec  {
    static func dec(_ : Any) -> Self?
    func enc() -> Any?
}


protocol EncDecEnum : EncDec, RawRepresentable, HasDefault
where RawValue : HasDefault {}

extension EncDecEnum {
    func enc() -> Any? { self.rawValue as Any }
    static func dec(_ x: Any) -> Self? {
        guard let m=x as? Self.RawValue else { return nil }
            return Self(rawValue: m)
    }
    
    

}



protocol Encodable : RawRepresentable, Codable where RawValue : Codable {
    init(_ r : Int)
}

extension Encodable {
    
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        let rv = try c .decode(Int.self)
        self.init(rv)
    }
    public func encode(to encoder: Encoder) throws {
        var c=encoder.singleValueContainer()
        try c.encode(self.rawValue)
    }
}

/// Special encodable enumerations
///

public protocol RawConstructibleEnumeration : RawRepresentable {
    static var zero : Self { get }
    
    init(_ : RawValue)
    var value : RawValue { get }
    
}

extension RawConstructibleEnumeration {
    
    public init(_ r : RawValue) { self=Self(rawValue: r) ?? Self.zero }
    public var value : RawValue { self.rawValue }
}

public protocol NameableEnumeration : CaseIterable, Hashable, Nameable, Decodable, EncDec {
    
    static var zero : Self { get }
    func zeroValue() -> Self 
    init(_ : String)
    
    
}

extension NameableEnumeration {
    public init(_ name : String) {
        self = (Self.allCases.first { $0.str==name }) ?? Self.zero
    }
    public var str : String { "\(self)" }
    
    public static func load(_ str: String) -> Self { Self(str) }
    public static func dec(_ x: Any) -> Self? {
        guard let name = x as? String else { return nil }
        return Self.load(name)
    }
    public func enc() -> Any? {
        self.str
    }
    
    public func zeroValue() -> Self { Self.zero }
    
    public var name : String { str }
}


