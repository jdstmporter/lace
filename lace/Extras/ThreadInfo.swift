//
//  ThreadInfo.swift
//  lace
//
//  Created by Julian Porter on 11/05/2022.
//

import Foundation

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

struct ThreadInfo {
    var material : String
    let thread : ThreadKind
    var laceKind : LaceKind {
        didSet {
            if !laceKind.isCustom { laceKindWraps = laceKind.wrapsPerSpace }
        }
    }
    var laceKindWraps : Int
    
    
    public init() {
        material="Custom"
        thread=ThreadKind()
        laceKind = .Torchon
        laceKindWraps=12
    }
    
    public var laceKindName : String {
        get { laceKind.name }
        set {
            laceKind = LaceKind(newValue)
            if !laceKind.isCustom { laceKindWraps = laceKind.wrapsPerSpace }
        }
    }
    public var threadName : String {
        get { thread.name }
        set { thread.setName(newValue) }
    }
    public var threadWraps : Int {
        get { thread.wraps }
        set { thread.setWrapping(newValue) }
    }
    
    var pinSpacing : Decimal {
        let raw = 10.0*self.laceKindWraps.f32/self.threadWraps.f32
        return raw.truncated
        
    }
    
    
 
    
}

