//
//  dataTypes.swift
//  lace
//
//  Created by Julian Porter on 29/04/2023.
//

import Foundation
import CoreData

extension PrickingData {
    
    
    
    var laceKind : LaceKind? { LaceKind(rawValue: numericCast(self.kind)) }
    
    var pricking : Pricking {
        Pricking(numericCast(self.width),numericCast(self.height),name: self.name ?? "",
                 kind: self.laceKind ?? .Torchon )
    }
    
    static func make(in context: NSManagedObjectContext,named : String, width: Int, height: Int, kind: LaceKind) -> PrickingData {
        var obj = PrickingData.init(context: context)
        obj.name = named
        obj.width = numericCast(width)
        obj.height = numericCast(height)
        obj.kind = numericCast(kind.rawValue)
        obj.uid = UUID()
        obj.created = Date()
        return obj
    }
    static func make(in context: NSManagedObjectContext,from pricking: Pricking) -> PrickingData {
        make(in: context, named: pricking.name, width: pricking.width, height: pricking.height, kind: pricking.kind)
    }
}

extension LaceKind {
    init(_ intValue : Int32) {
        self = LaceKind(rawValue: numericCast(intValue)) ?? .Torchon
    }
}

struct PrickingSpecification {
    
    let name : String
    let width : Int
    let height : Int
    let kind : LaceKind
    let uid : UUID
    
    var mirror : Mirror!
    
    init(name: String,width: Int,height : Int, kind : LaceKind, uid : UUID) {
        self.name=name
        self.width=width
        self.height=height
        self.kind=kind
        self.uid=uid
        
        self.mirror = Mirror(reflecting: self)
    }
    init(name: String?,width: Int32,height : Int32, kind : Int32, uid : UUID?) {
        self.init(name: name ?? "", width: numericCast(width), height: numericCast(height), kind: LaceKind(kind), uid: uid ?? UUID())
    }
    init(_ item : PrickingData) {
        self.init(name: item.name,width:item.width,height:item.height,kind:item.kind,uid:item.uid)
    }
    init() {
        self.init(name: "default",width:1,height:1,kind: .Torchon,uid: UUID(uuid: UUID_NULL))
    }
    
    subscript<T>(_ label: String) -> T? {
        (self.mirror.children.first { $0.label == label })?.value as? T
    }
    
    
    
}
