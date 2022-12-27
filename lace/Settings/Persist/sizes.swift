//
//  sizes.swift
//  lace
//
//  Created by Julian Porter on 26/12/2022.
//

import Foundation

struct GridSize : CustomStringConvertible, Equatable, Codable {
    let width: Int
    let height: Int
    
    var width32: Int32 { numericCast(width) }
    var height32: Int32 { numericCast(height) }
    
    enum CodingKeys : String, CodingKey {
        case width
        case height
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.width = try c.decode(Int.self,forKey: .width)
        self.height = try c.decode(Int.self,forKey: .height)
    }
    
    func encode(to encoder: Encoder) throws {
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.width,forKey : .width)
        try c.encode(self.height,forKey : .height)
    }
    
    init(_ w : Int = 1,_ h : Int = 1) {
        self.width=w
        self.height=h
    }
    
    var description: String { "\(width) x \(height)" }
    
    static func==(_ l : GridSize,_ r : GridSize) -> Bool {
        l.width==r.width && l.height==r.height
    }
    
    

}
