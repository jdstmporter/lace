//
//  Grid.swift
//  lace
//
//  Created by Julian Porter on 03/04/2022.
//

import Foundation
import Combine


enum GridError : Error {}


class Grid : Codable {
    
    enum CodingKeys : String, CodingKey {
        case width
        case height
        case scale
        case points
    }
    
    
    let width : Int
    let height : Int
    
    var scale : Double
    //var data : [[Bool]]=[]
    var data : [Bool] = []
    var size : Int { width*height }
    var xRange : Range<Int> { 0..<width }
    var yRange : Range<Int> { 0..<height }
    var xyRange : [(Int,Int)] { self._apply { (x,y) in (x,y) }}
    var pointRange : [GridPoint] { xyRange.map { GridPoint($0.0,$0.1) } }
    
    private func _apply<T>(_ f: (Int,Int) -> T?) -> [T] {
        (0..<width).flatMap { x in
            (0..<height).compactMap { y in f(x,y) }
        }
    }
    private func _idx(_ x : Int, _ y : Int) -> Int { x+(y*width) }
    private func _idx(_ p : GridPoint) -> Int { p.x+(p.y*width) }
    
    public init(width : Int, height: Int) {
        self.width=width
        self.height=height
        self.scale=1.0
        self.reset()
    }
    
    public required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.width = try c.decode(Int.self,forKey: .width)
        self.height = try c.decode(Int.self,forKey: .height)
        self.scale = try c.decode(Double.self,forKey: .scale)
        //self.data = try c.decode([[Bool]].self,forKey: .data)
        let points = try c.decode([GridPoint].self,forKey: .points)
        
        self.reset()
        points.forEach { self[$0]=true }
    }
    public func encode(to encoder: Encoder) throws {
        
        let points : [GridPoint]=self._apply { (x,y) in
            guard self[x,y] else { return nil }
            return GridPoint(x,y)
        }
        
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.width,forKey : .width)
        try c.encode(self.height,forKey : .height)
        try c.encode(self.scale,forKey : .scale)
        //try c.encode(self.data,forKey : .data)
        try c.encode(points,forKey : .points)
        
        
    }
    
    public subscript(_ x : Int, _ y : Int) -> Bool {
        //get { self.data[y][x] }
        //set { self.data[y][x] = newValue }
        get { self.data[self._idx(x,y)] }
        set(v) { self.data[self._idx(x,y)]=v }
    }
    public subscript(_ p : GridPoint) -> Bool {
        get { self.data[self._idx(p)] }
        set(v) { self.data[self._idx(p)]=v }
    }
    //func flip(_ p : GridPoint) { self.data[p.y][p.x].toggle() }
    //func reset() { self.data = (0..<height).map { _ in [Bool].init(repeating: false, count: width) } }
    public func flip(_ p : GridPoint) { self.data[self._idx(p.x,p.y)].toggle() }
    public func reset() { self.data=[Bool].init(repeating: false, count: size) }
    
    public func check(_ x : Int, _ y : Int) -> Bool { xRange.contains(x) && yRange.contains(y) }
    public func check(_ p : GridPoint) -> Bool { check(p.x,p.y) }
 
}

