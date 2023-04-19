//
//  Trivalent.swift
//  lace
//
//  Created by Julian Porter on 19/04/2023.
//

import Foundation

enum DataState: Int {
    case Good = 1
    case Bad = 2
    case Unset = 0
    
    var str : String { "\(self)" }
    var int : Int { self.rawValue }
    
}

actor Trivalent<T> {
    private(set) var initialised : Bool
    private(set) var obj : T?
    
    var good : Bool { initialised && (obj != nil ) }
    var bad : Bool { initialised && (obj == nil ) }
    var unset : Bool { !initialised }
    
    var state : DataState {
        guard initialised else { return .Unset }
        return (obj != nil) ? .Good : .Bad
    }
    
    init() {
        initialised = false
        obj = nil
    }
    
    @discardableResult func set(_ o : T?) -> DataState {
        if !self.initialised {
            self.obj = o
            self.initialised = true
        }
        return self.state
    }
}

