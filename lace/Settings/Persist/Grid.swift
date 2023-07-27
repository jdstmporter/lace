//
//  Grid.swift
//  lace
//
//  Created by Julian Porter on 03/04/2022.
//

import Foundation
import Combine
import BitArray


enum GridError : Error {}


extension BitArray {
    func toggle(_ idx : Int) {
        self[idx] = !self[idx]
    }
}


class Grid : Codable {
    
    var size : GridSize
    var data : BitArray
    
    var width : Int32 { self.size.width }
    var height : Int32 { self.size.height }
    var count : Int { numericCast(self.size.count) }
    
    public init(size : GridSize,data : BitArray) {
        self.size=size
        self.data=BitArray(data)
    }
    public convenience init(size: GridSize) {
        let d=BitArray(nBits: numericCast(size.count))
        self.init(size: size,data: d)
    }
    
    public convenience init(width : Int32, height : Int32) {
        self.init(size: GridSize(width,height))
    }
    
    public init(width : Int32, height: Int32,data : BitArray) {
        self.size = GridSize(width,height)
        let n = Swift.min(self.count,data.nBits)
        self.data=BitArray(bytes:data.bytes,nBits: n)
    }
    
    public convenience init(_ specification: PrickingSpecification) {
        self.init(size: specification.size,data : specification.grid)
    }
    
    // coding
    
    enum CodingKeys : CodingKey {
        case size
        case data
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.size = try values.decode(GridSize.self, forKey: .size)
        self.data = try values.decode(BitArray.self, forKey: .data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.size, forKey: .size)
        try values.encode(self.data, forKey: .data)
    }
    
    // Range-based values
    
    public var xRange : Range<Int32> { 0..<width }
    public var yRange : Range<Int32> { 0..<height }
    public var xyRange : [(Int32,Int32)] { self._apply { (x,y) in (x,y) }}
    public var pointRange : [GridPoint] { xyRange.map { GridPoint($0.0,$0.1) } }
    
    private func _apply<T>(_ f: (Int32,Int32) -> T?) -> [T] {
        (0..<width).flatMap { x in
            (0..<height).compactMap { y in f(x,y) }
        }
    }
    
    // Indexing
    
    private func _idx(_ x : Int32, _ y : Int32) -> Int { numericCast(x+(y*width)) }
    private func _idx(_ p : GridPoint) -> Int { numericCast(p.x+(p.y*width)) }
    
    public subscript(_ x : Int32, _ y : Int32) -> Bool {
        get { self.data[self._idx(x,y)] }
        set(v) { self.data[self._idx(x,y)]=v }
    }
    public subscript(_ p : GridPoint) -> Bool {
        get { self.data[self._idx(p)] }
        set(v) { self.data[self._idx(p)]=v }
    }
    
    // data functions
    
    public func flip(_ p : GridPoint) { self.data.toggle(self._idx(p.x,p.y)) }
    public func reset() { self.data=BitArray(nBits: self.count) } //Array<Bool>(repeating: false, count: size) }
    
    public func check(_ x : Int32, _ y : Int32) -> Bool { xRange.contains(x) && yRange.contains(y) }
    public func check(_ p : GridPoint) -> Bool { check(p.x,p.y) }
 
}

