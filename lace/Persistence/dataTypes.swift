//
//  dataTypes.swift
//  lace
//
//  Created by Julian Porter on 29/04/2023.
//

import Foundation
import CoreData
import BitArray


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




class PrickingSpecification : CustomStringConvertible, Identifiable {
    typealias ID = UUID
    
    enum Errors : Error {
        case ValueWithoutUUID
        case ValueWithoutTimeStamp
    }
    
    var data : [Columns : Any] = [:]
    
    let name : String
    let width : Int
    let height : Int
    let kind : LaceKind
    var grid : BitArray
    let uid : UUID
    var created : Date

    var mirror : Mirror!
    
    init(name: String,width: Int,height : Int, kind : LaceKind,
         grid : BitArray,
         uid : UUID = UUID(), created : Date = Date.now) {
        self.name=name
        self.width=width
        self.height=height
        self.kind=kind
        self.grid=grid
        self.uid=uid
        self.created=created
        
        self.mirror = Mirror(reflecting: self)
    }
    convenience init(name: String,width: Int,height : Int, kind : LaceKind,
                     uid : UUID = UUID(), created : Date = Date.now) {
        self.init(name: name, width: width, height: height, kind: kind,
                  grid: BitArray(nBits: width*height), uid : uid, created : created)
    }
    
    convenience init() {
        let timestamp=TimeStamp()
        self.init(name: "pricking \(timestamp)",width: 1,height: 1, kind: .Torchon,
                  grid: BitArray(nBits: 1), created: timestamp.date)
    }
    
    convenience init?(_ obj : PrickingData) {
        guard let uid = obj.uid, let created = obj.created else { return nil }

        self.init(name: obj.name ?? "", width: obj.w, height: obj.h, kind: LaceKind(obj.kind),
                  grid: obj.grid, uid: uid, created: created)
    }
    
    var id : ID { self.uid }
    
    subscript<T>(_ label: String) -> T? {
        (self.mirror.children.first { $0.label == label })?.value as? T
    }
    subscript<T>(_ c : Columns) -> T? { self[c.str] }
    
    var description: String {
        "\(name) : \(width) pins x \(height) rows, \(kind) lace, created \(TimeStamp(created))"
    }
    
    
}
