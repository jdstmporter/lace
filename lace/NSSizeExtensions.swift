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

extension Float {
    
    var i32 : Int { Int(self) }
    
    func truncated(nDecimals: Int) -> Float {
//        let factor : Float = (0..<nDecimals).reduce(1.0) { (res,_) in 10.0*res }
//        let rnd = (self*factor).rounded().i32
 //       return rnd.f32/factor
        let factor : Float = (0..<nDecimals).reduce(1.0) { (res,_) in 10.0*res }
        return roundf(factor*self)/factor
    }
    var truncated : Decimal {
        var d=Decimal.init(Double(self))
        var e = Decimal.init(0.0)
        NSDecimalRound(&e, &d, 1, .plain)
        return e
    }
}

extension Array {
    var copy : [Element] { self.map { $0 } }
    var asStrings : [String] { self.map { "\($0)" } }
}

