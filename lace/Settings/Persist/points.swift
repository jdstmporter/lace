//
//  models.swift
//  lace
//
//  Created by Julian Porter on 26/12/2022.
//

import Foundation

enum DecodeError : Error {
    case BadCoordinate
}

struct GridPoint : CustomStringConvertible, Comparable, Equatable, Hashable, Codable {
    let x : Int
    let y : Int
    
    enum CodingKeys : CodingKey {
        case x
        case y
    }
    
    init(_ x : Int, _ y : Int) {
        self.x=x
        self.y=y
    }
    
    var adjustedX : Double {
        let xx=Double(self.x)
        return (y%2 == 1) ? xx+0.5 : xx
    }
    
    var description: String { " (\(x),\(y))"}
    
    static func==(_ l : GridPoint,_ r : GridPoint) -> Bool {
        l.x==r.x && l.y==r.y
    }
    static func < (lhs: GridPoint, rhs:GridPoint) -> Bool {
        (lhs.y < rhs.y) || (lhs.y==rhs.y && lhs.x<rhs.x)
    }
    
    func hash(into hasher: inout Hasher) {
        x.hash(into: &hasher)
        y.hash(into: &hasher)
    }
    
   
    
    
    
}
