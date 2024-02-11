//
//  Grid.swift
//  lace
//
//  Created by Julian Porter on 03/04/2022.
//

import Foundation
import AppKit
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
    
    // unique initialisers
    
    public init(size : GridSize,data : BitArray) {
        self.size=size
        self.data=BitArray(data)
    }
    public convenience init(size: GridSize) {
        let d=BitArray(nBits: numericCast(size.count))
        self.init(size: size,data: d)
    }
    
    public convenience init(width : Int, height : Int) {
        self.init(size: GridSize(width,height))
    }
    
    public init(width : Int, height: Int,data : BitArray) {
        self.size = GridSize(width,height)
        let n = Swift.min(numericCast(width*height),data.nBits)
        self.data=BitArray(bytes:data.bytes,nBits: n)
    }
    
    // Convenience accessors
    
    var width : Int { self.size.width }
    var height : Int { self.size.height }
    var count : Int { self.size.count }
    
    // ranges
    
    private func _apply<T>(_ f: (Int,Int) -> T?) -> [T] {
        (0..<width).flatMap { x in
            (0..<height).compactMap { y in f(x,y) }
        }
    }
    
    public var xRange : Range<Int> { 0..<width }
    public var yRange : Range<Int> { 0..<height }
    public var xyRange : [(Int,Int)] { self._apply { (x,y) in (x,y) }}
    public var pointRange : [GridPoint] { xyRange.map { GridPoint($0.0,$0.1) } }
    
    // Indexing
    
    private func _idx(_ x : Int, _ y : Int) -> Int { x+(y*width) }
    private func _idx(_ p : GridPoint) -> Int { p.x+(p.y*width) }
    
    public subscript(_ x : Int, _ y : Int) -> Bool {
        get { self.data[self._idx(x,y)] }
        set(v) { self.data[self._idx(x,y)]=v }
    }
    public subscript(_ p : GridPoint) -> Bool {
        get { self.data[self._idx(p)] }
        set(v) { self.data[self._idx(p)]=v }
    }
    
    // data modification functions
    
    public func flip(_ p : GridPoint) { self.data.toggle(self._idx(p.x,p.y)) }
    public func reset() { self.data=BitArray(nBits: self.count) } //Array<Bool>(repeating: false, count: size) }
    
    public func check(_ x : Int, _ y : Int) -> Bool { xRange.contains(x) && yRange.contains(y) }
    public func check(_ p : GridPoint) -> Bool { check(p.x,p.y) }
 
}



extension Grid {
    
    
    func updateTracking(view : LaceView) {
        let conv=view.pricking.converter
        
        self.yRange.forEach { y in
            self.xRange.forEach { x in
                let p = view.invert(conv.pos(x,y))
                let r = NSRect(centre: p, side: view.pricking.scale)
                syslog.announce("(\(x),\(y)) -|> \(r)   [\(view.pricking.scale)]")
                let area = NSTrackingArea(rect: r,
                                          options: [.mouseEnteredAndExited,.activeInKeyWindow],
                                          owner: self,
                                          userInfo: ["x" : x, "y" : y])
                view.addTrackingArea(area)
                view.tracker.append(area)
            }
        }
    }
    
    func draw(view : LaceView) {
        
        let conv=view.pricking.converter
        self.yRange.forEach { y in
            self.xRange.forEach { x in
                let isPin = view.pricking[x,y]
                let pinData : ViewPart = isPin ? .Pin : .Grid
                let radius = view.dims[pinData]
                let fg : NSColor = view.colours[pinData]
                let p = conv.pos(x, y)
                view.point(p,radius: radius,colour: fg)
                
            }
        }
    }
}

