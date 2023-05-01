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

extension UUID {
    static var Null : UUID { UUID(uuid: UUID_NULL) }
}

struct PrickingSpecification {
    
    let name : String
    let width : Int
    let height : Int
    let kind : LaceKind
    var uid : UUID
    var created : Date?
    
    var mirror : Mirror!
    
    init(name: String,width: Int,height : Int, kind : LaceKind, uid : UUID? = nil, created : Date? = nil) {
        self.name=name
        self.width=width
        self.height=height
        self.kind=kind
        self.uid=uid ?? UUID.Null
        self.created=created
        
        
        self.mirror = Mirror(reflecting: self)
    }
    init(name: String?,width: Int32,height : Int32, kind : Int32, uid : UUID? = nil,created : Date? = nil) {
        self.init(name: name ?? "", width: numericCast(width), height: numericCast(height), kind: LaceKind(kind), uid: uid,created: created)
    }
    init(_ item : PrickingData) {
        self.init(name: item.name,width:item.width,height:item.height,kind:item.kind,uid:item.uid,created:item.created)
    }
    init() {
        self.init(name: "default",width:1,height:1,kind: .Torchon)
    }
    
    subscript<T>(_ label: String) -> T? {
        (self.mirror.children.first { $0.label == label })?.value as? T
    }
    
    mutating func finalise() {
        self.uid = UUID()
        self.created=Date()
    }
    
    var isUnsaved : Bool { created == nil || uid == UUID.Null }
    
    
    
    
    
}
