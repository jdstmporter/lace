//
//  codablePricking.swift
//  lace
//
//  Created by Julian Porter on 29/04/2023.
//

import Foundation

extension LaceKind : Codable {
    enum CodingKeys : String, CodingKey {
        case raw
    }
    enum CKError : Error {
        case BadRawValue
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let raw = try c.decode(Int.self, forKey: .raw)
        guard let s = LaceKind(rawValue: raw) else { throw CKError.BadRawValue }
        self = s
    }
    
    func encode(to encoder: Encoder) throws {
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.rawValue,forKey: .raw)
    }
}

extension Pricking : Codable {
    
    enum CodingKeys : String, CodingKey {
        case grid
        case lines
        case scale
        case name
        case kind
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.grid = try c.decode(Grid.self,forKey: .grid)
        self.lines = try c.decode(Lines.self,forKey: .lines)
        self.scale = try c.decode(Double.self,forKey: .scale)
        self.name = try c.decode(String.self,forKey: .name)
        self.kind = try c.decode(LaceKind.self,forKey: .kind)
    }
    
    func encode(to encoder: Encoder) throws {
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.grid,forKey : .grid)
        try c.encode(self.lines,forKey : .lines)
        try c.encode(self.scale,forKey : .scale)
        try c.encode(self.name,forKey : .name)
        try c.encode(self.kind,forKey : .kind)
    }
    
    
}
