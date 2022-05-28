//
//  NSSizeExtensions.swift
//  lace
//
//  Created by Julian Porter on 24/05/2022.
//

import Foundation
import AppKit

extension NSSize {
    init(_ res : PMResolution) { self.init(width: res.hRes, height: res.vRes) }
    init(side: Int) { self.init(width: side,height: side) }
    
    func mult(_ f : Double) -> NSSize { NSSize(width: f*width, height: f*height) }
    func div(_ f : Double) -> NSSize { NSSize(width: width/f, height: height/f) }
    
    var widthI : Int { numericCast(width) }
    var heightI : Int { numericCast(height) }
    var area : Int { widthI*heightI }
    
    
    
    static func * (_ s : NSSize,_ f : Double) -> NSSize { NSSize(width: s.width*f,height: s.height*f) }
    static func * (_ s : NSSize,_ i : Int) -> NSSize { s*Double(i) }
}

extension Int {
    var f32 : Float { Float(self) }
    
    func clip(_ min: Int,_ max: Int) -> Int  { Swift.min(max,Swift.max(min,self))}
}

