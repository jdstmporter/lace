//
//  LaceKinds.swift
//  lace
//
//  Created by Julian Porter on 11/05/2022.
//

import Foundation




enum LaceKind : Int, NameableEnumeration, RawConstructibleEnumeration {
    
    
    
    case Milanese = 0
    case Bedfordshire = 1
    case PointGround = 2
    case Bruges = 3
    case Torchon = 4
    case Valenceniennes = 5
    case Binche = 6
    case Flanders = 7
    
    case Custom = 8
    
    static var zero: LaceKind { .Custom }

    static let windings : [LaceKind:Int] = [
        .Milanese : 8,
        .Bedfordshire : 9,
        .PointGround : 10,
        .Bruges : 11,
        .Torchon : 12,
        .Valenceniennes : 16,
        .Flanders : 18,
        .Binche : 18
    ]
    static let names : [LaceKind:String] = [
        .Milanese : "Milanese",
        .Bedfordshire : "Bedfordshire",
        .PointGround : "Point Ground",
        .Bruges : "Bruges",
        .Torchon : "Torchon",
        .Valenceniennes : "Valenceniennes",
        .Flanders : "Flanders",
        .Binche : "Binche",
        .Custom : "Custom"
    ]
    
    
    var name : String { LaceKind.names[self] ?? "" }
    var str : String { name }
    var wrapsPerSpace : Int { LaceKind.windings[self] ?? 12 }
    var isCustom : Bool { self == .Custom }
    
    init(_ n : String?) { self = LaceKind(n ?? "") }
    init(fromSafeString s : String) throws {
        guard let x = (LaceKind.allCases.first { $0.str == s }) else { throw LaceError.BadLaceStyleName }
        self = x
    }
    
    static var count : Int { LaceKind.allCases.count }
    init(index: Int) { self = LaceKind(index) }
    var index : Int { self.value }
    
    
    
    
    
    

}



 
