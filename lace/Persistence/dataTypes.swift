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
        let obj = PrickingData.init(context: context)
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
extension Date {
    var slug : String {
        self.ISO8601Format(.iso8601.year().month().day().dateSeparator(.dash)
            .dateTimeSeparator(.space).time(includingFractionalSeconds: false).timeSeparator(.colon))
    }
}

enum Columns : Int, RawRepresentable, CaseIterable {
    typealias RawValue = Int
    
    static var fullNames : [Self:String] = [
        .name : "Name",
        .width : "Width",
        .height : "Height",
        .kind : "Lace Kind"
    ]
    
    case name = 1
    case width = 2
    case height = 3
    case kind = 4
    case uid = 5
    case created = 6
    
    init(_ r : RawValue) { self = Self(rawValue: r) ?? .name }
    public init(_ name : String) {
        self = (Self.allCases.first { $0.str==name }) ?? .name
    }
    
    
    var str : String { "\(self)" }
    var name : String { Self.fullNames[self] ?? "default" }
    var idx : Int { self.rawValue - 1 }
    
}

struct PrickingSpecification : CustomStringConvertible {
    
    var data : [Columns : Any] = [:]
    
    let name : String
    let width : Int
    let height : Int
    let kind : LaceKind
    let uid : UUID
    var created : Date?

    
    var mirror : Mirror!
    
    
    init(name: String,width: Int,height : Int, kind : LaceKind, uid : UUID? = nil, created : Date? = nil) {
        self.name=name
        self.width=width
        self.height=height
        self.kind=kind
        self.uid=uid ?? UUID()
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
    subscript<T>(_ c : Columns) -> T? { self[c.str] }
    
    mutating func finalise() { created=Date.now }
  
    
    var isUnsaved : Bool { created == nil }
    
    
    var description: String {
        "\(name) : \(width) pins x \(height) rows, \(kind) lace, created \(created?.formatted() ?? "n/a")"
    }
    
    
}
