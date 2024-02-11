//
//  Layer.swift
//  lace
//
//  Created by Julian Porter on 10/02/2024.
//

import Foundation

enum LayerKind : Int, RawConstructibleEnumeration, Codable {
    static var zero: LayerKind = .Unknown
    
    typealias RawValue = Int
    
    case Unknown = 0
    case Grid = 1
    case Lines = 2
    case Spiders = 3
    case Gimp = 4
    case Fans = 5
    case Text = 6
    
    enum CodingKeys : String, CodingKey {
        case value = "kind"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.value, forKey: .value)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idx = try container.decode(Int.self, forKey: .value)
        self = LayerKind(idx)
    }
    
}
enum LayerCodingKeys : String, CodingKey {
    case name
    case kind
    case items
}



class LayerBase<T> where T : Codable {
    
    var name : String = ""
    var kind : LayerKind = .Unknown
    var items : [T] = []
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: LayerCodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.items, forKey: .items)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LayerCodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.kind = try container.decode(LayerKind.self, forKey: .kind)
        self.items = try container.decode(Array<T>.self, forKey: .items)
    }
    
}
