//
//  grid2screen.swift
//  lace
//
//  Created by Julian Porter on 27/12/2022.
//

import Foundation
import AppKit

extension NSPoint {
    static func *(_ l : Double, _ r : NSPoint) -> NSPoint { NSPoint(x: l*r.x, y: l*r.y) }
    static func *(_ r : NSPoint, _ l : Double) -> NSPoint { NSPoint(x: l*r.x, y: l*r.y) }
}

struct Convert {
    
    let scale : Double
    
    init(_ scale : Double = 1.0) { self.scale = scale }
    
    func pos(_ x : Int, _ y : Int) -> NSPoint {
        let py = Double(y)+1.0
        let offset = 0.5*Double(y%2)
        let px = Double(x)+offset+1.0
        return NSPoint(x: px, y: py)*scale
    }
    func pos(_ p : GridPoint) -> NSPoint { self.pos(p.x,p.y) }
    
    
    func round(_ d : Double) -> Int { Int((d/scale).rounded()) }
    
    func nearest(_ p : NSPoint) -> GridPoint {
        let y = round(p.y)-1
        let offset = 0.5*Double(y%2)*scale
        let x = round(p.x-offset)-1
        //print("Rounding: (\(p.x),\(p.y)) and offset \(p.x-offset) to (\(x),\(y))")
        return GridPoint(x, y)
    }
    func nearestPoint(_ p : NSPoint) -> NSPoint { self.pos(self.nearest(p)) }
    
    
}
