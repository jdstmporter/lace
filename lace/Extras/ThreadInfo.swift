//
//  ThreadInfo.swift
//  lace
//
//  Created by Julian Porter on 11/05/2022.
//

import Foundation



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
            laceKind = LaceKind(newValue) ?? .Custom
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

