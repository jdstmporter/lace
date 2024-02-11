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
    
    init(_ w : Int = 1,_ h : Int = 1) {
        self.width=w
        self.height=h
    }
    
    var count : Int { width*height }
    
    var description: String { "\(width) x \(height)" }
    
    static func==(_ l : GridSize,_ r : GridSize) -> Bool {
        l.width==r.width && l.height==r.height
    }
    
    

}


struct GridRect : CustomStringConvertible, Equatable, Codable {
    let origin: GridPoint
    let size: GridSize
    
    init(_ x : Int = 0, _ y : Int = 0,_ w : Int = 1,_ h : Int = 1) {
        self.origin=GridPoint(x,y)
        self.size=GridSize(w,h)
    }
    init(_ o : GridPoint, _ s : GridSize) {
        self.origin=o
        self.size=s
    }
    
    var offsetX : Int { origin.x }
    var offsetY : Int { origin.y }
    var width : Int { size.width }
    var height : Int {size.height }
    
    
    var description: String { "\(self.origin) \(self.size)" }
    
    static func==(_ l : GridRect,_ r : GridRect) -> Bool {
        l.origin==r.origin && l.size==r.size
    }
    
    

}

