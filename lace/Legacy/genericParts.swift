//
//  genericParts.swift
//  lace
//
//  Created by Julian Porter on 10/09/2022.
//

import Foundation

protocol IfaceP {
    associatedtype Value
    
    subscript(_: ViewPart) -> Value { get }
}

class Generic<Value,Iface>
where Value : HasDefault, Value.V==Value, Iface : IfaceP, Iface.Value==Value {
    typealias Container=[ViewPart:Value]
    typealias Iterator = Container.Iterator
    private var values : Container = [:]
    
    required public init() { self.update() }
    public init(copy: Iface) {
        self.copy(copy)
    }
    
    private func defaultValue(_ p : ViewPart) -> Value { .zero  }
    
    subscript(_ p: ViewPart) -> Value {
        get { self.values[p] ?? defaultValue(p) }
        set { self.values[p] = newValue }
    }
    
    func copy(_ o: Iface) {
        self.values.removeAll()
        ViewPart.allCases.forEach { self.values[$0] = o[$0] }
    }
    func update() {  }
    
    func commit() throws {
        
    }
    
    static func empty() -> Self { Self() }
    
}
