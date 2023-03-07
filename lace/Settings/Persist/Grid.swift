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
        case points
    }
    
    
    let width : Int
    let height : Int
    
    //var scale : Double
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
    
    public init(width : Int, height: Int,data : [Bool]=[]) {
        self.width=width
        self.height=height
        
        self.reset()
        let n = Swift.min(self.size,data.count)
        (0..<n).forEach { self.data[$0] = data[$0] }
    }
    
    public required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.width = try c.decode(Int.self,forKey: .width)
        self.height = try c.decode(Int.self,forKey: .height)
        
        let points = try c.decode(String.self,forKey: .points)
        
        self.reset()
        let dp : [Bool] = points.prefix(self.size).map { $0=="1" }
        self.data.replaceSubrange(0..<dp.count, with: dp)
        (0..<dp.count).forEach { self.data[$0]=dp[$0] }
        
        //points.forEach { self[$0]=true }
    }
    public func encode(to encoder: Encoder) throws {
        
        let points : String = self.data.map { $0 ? "1" : "0" }.joined(separator: "")
        
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.width,forKey : .width)
        try c.encode(self.height,forKey : .height)
        
        try c.encode(points,forKey : .points)
        
        
    }
    
    public subscript(_ x : Int, _ y : Int) -> Bool {
        get { self.data[self._idx(x,y)] }
        set(v) { self.data[self._idx(x,y)]=v }
    }
    public subscript(_ p : GridPoint) -> Bool {
        get { self.data[self._idx(p)] }
        set(v) { self.data[self._idx(p)]=v }
    }
    public func flip(_ p : GridPoint) { self.data[self._idx(p.x,p.y)].toggle() }
    public func reset() { self.data=Array<Bool>(repeating: false, count: size) }
    
    public func check(_ x : Int, _ y : Int) -> Bool { xRange.contains(x) && yRange.contains(y) }
    public func check(_ p : GridPoint) -> Bool { check(p.x,p.y) }
 
}

