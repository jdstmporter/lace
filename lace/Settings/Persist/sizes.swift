//
//  sizes.swift
//  lace
//
//  Created by Julian Porter on 26/12/2022.
//

import Foundation

struct GridSize : CustomStringConvertible, Equatable, Codable {
    let width: Int32
    let height: Int32
    
    init(_ w : Int32 = 1,_ h : Int32 = 1) {
        self.width=w
        self.height=h
    }
    
    var count : Int { numericCast(width*height) }
    
    var description: String { "\(width) x \(height)" }
    
    static func==(_ l : GridSize,_ r : GridSize) -> Bool {
        l.width==r.width && l.height==r.height
    }
    
    

}
