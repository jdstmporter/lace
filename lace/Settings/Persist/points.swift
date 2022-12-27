//
//  models.swift
//  lace
//
//  Created by Julian Porter on 26/12/2022.
//

import Foundation

struct GridPoint : CustomStringConvertible, Comparable, Equatable, Codable {
    let x : Int
    let y : Int
    
    var x32 : Int32 { numericCast(x) }
    var y32 : Int32 { numericCast(y) }
    
    enum CodingKeys : String, CodingKey {
        case x
        case y
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.x = try c.decode(Int.self,forKey: .x)
        self.y = try c.decode(Int.self,forKey: .y)
    }
    
    func encode(to encoder: Encoder) throws {
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.x,forKey : .x)
        try c.encode(self.y,forKey : .y)
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
}
