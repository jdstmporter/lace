//
//  layers.swift
//  lace
//
//  Created by Julian Porter on 27/07/2023.
//

import Foundation
import CoreData

enum LayerKind : Int32, RawConstructibleEnumeration, Codable {
    static var zero: LayerKind = .Unknown
    
    typealias RawValue = Int32
    
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
        let idx = try container.decode(Int32.self, forKey: .value)
        self = LayerKind(idx)
    }
    
}


protocol PrickingLayer : Codable {
    var index : Int { get set }
    static var layer : LayerKind { get }
    var name : String { get set }
    
}




extension DataLayer {
    
    func attach(to pricking: DataPricking) { self.parent=pricking.uuid }
    func detach() { self.parent=nil }
    
    var layerKind : LayerKind {
        get { LayerKind(self.kind) }
        set { self.kind=newValue.rawValue }
    }
    
    static func make<T>(in moc: NSManagedObjectContext,name : String="Default",kind : LayerKind,parent: DataPricking,index : Int32 = -1) -> T where T : DataLayer {
        var item=T.init(context: moc)
        item.name=name
        item.layerKind=kind
        item.index=index
        item.parent=parent.uuid
        return item
    }
}

