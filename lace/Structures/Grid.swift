//
//  Grid.swift
//  lace
//
//  Created by Julian Porter on 03/04/2022.
//

import Foundation






class Grid : Codable {
    
    enum CodingKeys : String, CodingKey {
        case width
        case height
        case scale
        case data
    }
    
    
    let width : Int
    let height : Int
    
    var scale : Double
    var data : [[Bool]]
    
    
    
    
    init(width : Int, height: Int) {
        self.width=width
        self.height=height
        self.scale=1.0
        
        self.data = (0..<height).map { _ in [Bool].init(repeating: false, count: width) }
    }
    
    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.width = try c.decode(Int.self,forKey: .width)
        self.height = try c.decode(Int.self,forKey: .height)
        self.scale = try c.decode(Double.self,forKey: .scale)
        self.data = try c.decode([[Bool]].self,forKey: .data)
    }
    func encode(to encoder: Encoder) throws {
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.width,forKey : .width)
        try c.encode(self.height,forKey : .height)
        try c.encode(self.scale,forKey : .scale)
        try c.encode(self.data,forKey : .data)
    }
    
    var xRange : Range<Int> { 0..<width }
    var yRange : Range<Int> { 0..<height }
    
    subscript(_ x : Int, _ y : Int) -> Bool {
        get { self.data[y][x] }
        set { self.data[y][x] = newValue }
    }
    subscript(_ p : GridPoint) -> Bool { self[p.x,p.y] }
    func flip(_ p : GridPoint) {
        self.data[p.y][p.x].toggle()
    }
    
    func pos(_ x : Int, _ y : Int) -> NSPoint {
        let py = Double(y)+1.0
        let offset = 0.5*Double(y%2)
        let px = Double(x)+offset+1.0
        return NSPoint(x: px*scale, y: py*scale)
    }
    func pos(_ p : GridPoint) -> NSPoint { self.pos(p.x,p.y) }
    func pos(_ l : GridLine) -> Line { Line(self.pos(l.start),self.pos(l.end)) }
    
    func round(_ d : Double) -> Int { Int((d/scale).rounded()) }
    
    func nearest(_ p : NSPoint) -> GridPoint {
        let y = round(p.y)-1
        let offset = 0.5*Double(y%2)*scale
        let x = round(p.x-offset)-1
        //print("Rounding: (\(p.x),\(p.y)) and offset \(p.x-offset) to (\(x),\(y))")
        return GridPoint(x, y)
    }
    func nearestPoint(_ p : NSPoint) -> NSPoint {
        self.pos(self.nearest(p))
    }
    
    
    
    func check(_ x : Int, _ y : Int) -> Bool {
        xRange.contains(x) && yRange.contains(y)
    }
    func check(_ p : GridPoint) -> Bool { check(p.x,p.y) }
    func check(_ p : NSPoint) -> Bool { check(nearest(p)) }
    
    
    
    func forEachX(_ f : (Int) -> Void ) { xRange.forEach { f($0) } }
    func forEachY(_ f : (Int) -> Void ) { yRange.forEach { f($0) } }
    
  
    
    
}

