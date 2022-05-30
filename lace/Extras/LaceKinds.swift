//
//  LaceKinds.swift
//  lace
//
//  Created by Julian Porter on 11/05/2022.
//

import Foundation




enum LaceKind : CaseIterable {
    case Milanese
    case Bedfordshire
    case PointGround
    case Bruges
    case Torchon
    case Valenceniennes
    case Binche
    case Flanders
    
    case Custom

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
    var str : String { "\(self)" }
    var wrapsPerSpace : Int { LaceKind.windings[self] ?? 12 }
    var isCustom : Bool { self == .Custom }
    
    init?(_ n : String) {
        guard let k = (LaceKind.allCases.first { $0.name == n }) else { return nil }
        self = k
    }
    init(fromSafeString s : String) throws {
        guard let x = (LaceKind.allCases.first { $0.str == s }) else { throw LaceError.BadLaceStyleName }
        self = x
    }
    
    

}



 
