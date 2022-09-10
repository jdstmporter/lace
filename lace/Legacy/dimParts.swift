//
//  dimParts.swift
//  lace
//
//  Created by Julian Porter on 10/09/2022.
//

import Foundation

protocol DimensionSetterProtocol {

    subscript(_: ViewPart) -> Double {get}
    func update()
    mutating func copy(_ o : DimensionSetterProtocol)
}

protocol DimensionSetterProtocol2 {

    subscript(_: ViewPart) -> Double {get}
    
    //func get(_ : ViewPart) -> Double
    //func set(_: ViewPart,_ : Double)
    func reload()
    func revert()
    func commit()
}

protocol ViewPartContainer : Sequence where Iterator == Container.Iterator {
    associatedtype Entry
    typealias Container = [ViewPart:Entry]
    
    
    static var PREFIX : String { get }
    
    var values : Container { get set }
    
    init()
    
    func defaultValue(_ p : ViewPart) -> Entry
     func key(_ p : ViewPart) -> String
     func load(_ p : ViewPart) throws -> Entry
     func save(_ p : ViewPart,_ v : Double) throws
    
    subscript(_ p : ViewPart) -> Entry { get set }
    func touch()
    func reset()
    func commit() throws
}

/*
class ViewDimensions : DimensionSetterProtocol2 {
    static let PREFIX = "Dimensions-"
    
    typealias Container=[ViewPart:Double]
    typealias Iterator = Container.Iterator
    private var values : Container = [:]
    private var temps : Container = [:]
    private var mode : LaceViewMode
    
    private func key(_ p : ViewPart) -> String { "\(ViewDimensions.PREFIX)\(p)" }
    public func load(_ p : ViewPart) -> Double? { Defaults.double(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : Double) { Defaults.setDouble(forKey: key(p), value: v) }
    public func has(_ p : ViewPart) -> Bool { values[p] != nil }
    
    public init(_ mode : LaceViewMode = .Permanent) {
        self.mode=mode
        self.reload()
    }
    
    public func reset() {
        self.values.removeAll()
        self.temps.removeAll()
    }
    public func reload() {
        self.reset()
        ViewPart.allCases.forEach { p in
            if let v = self.load(p) { self.values[p]=v }
        }
    }
    public func revert() {
        self.temps.removeAll()
    }
    
    private func defaultValue(_ p : ViewPart) -> Double { 1.0 }
    private func value(_ p : ViewPart) -> Double { self.values[p] ?? defaultValue(p) }
    
    subscript(_ p: ViewPart) -> Double {
        get {
            switch self.mode {
            case .Permanent:
                return self.value(p)
            case .Temporary:
                return self.temps[p] ?? self.value(p)
            }
        }
        set {
            switch self.mode {
            case .Permanent:
                self.values[p]=newValue
            case .Temporary:
                self.temps[p]=newValue
            }
        }
    }
 
    
    
    func commit() {
        self.values.merge(self.temps)
        ViewPart.allCases.forEach { p in
            if let v = self.temps[p] {
                self.values[p]=v
                self.save(p,v)
            }
        }
        self.revert()
    }
    
    static var instance : ViewDimensions { ViewDimensions() }
    
}
*/

class ViewPartsDimensionsTransient : DimensionSetterProtocol {
    
    typealias Container=[ViewPart:Double]
    typealias Iterator = Container.Iterator
    private var values : Container = [:]
    
    public init() { self.update() }
    public init(copy: DimensionSetterProtocol) {
        self.copy(copy)
    }
    
    private func defaultValue(_ p : ViewPart) -> Double { 1.0 }
    
    subscript(_ p: ViewPart) -> Double {
        get { self.values[p] ?? defaultValue(p) }
        set { self.values[p] = newValue }
    }
    
    func copy(_ o: DimensionSetterProtocol) {
        self.values.removeAll()
        ViewPart.allCases.forEach { self.values[$0] = o[$0] }
    }
    func update() {  }
    
    func commit() {
        ViewPartDimensions(copy: self).commit()
    }
    
    static func empty() -> DimensionSetterProtocol { ViewPartsDimensionsTransient() }
    static func defaults() -> DimensionSetterProtocol { ViewPartsDimensionsTransient(copy: ViewPartDimensions.defaults()) }
    
}

class ViewPartDimensions : DimensionSetterProtocol, Sequence {
    
    static let PREFIX = "Dimensions-"
    
    typealias Container=[ViewPart:Double]
    typealias Iterator = Container.Iterator
    private var values : Container = [:]
    
    public init() { self.update() }
    public init(copy: DimensionSetterProtocol) {
        self.copy(copy)
    }
    
    private func defaultValue(_ p : ViewPart) -> Double { 1.0 }
    private func key(_ p : ViewPart) -> String { "\(ViewPartDimensions.PREFIX)\(p)" }
    public func load(_ p : ViewPart) -> Double? { Defaults.double(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : Double) { Defaults.setDouble(forKey: key(p), value: v) }
    
    public subscript(_ p : ViewPart) -> Double {
        get { values[p] ?? defaultValue(p) }
        set { values[p] = newValue }
    }
    func copy(_ o: DimensionSetterProtocol) {
        self.values.removeAll()
        ViewPart.allCases.forEach { self.values[$0] = o[$0] }
    }
    public func touch() {
        ViewPart.allCases.forEach { p in
            if let c=values[p] { values[p]=c }
        }
    }
    public func commit() {
        ViewPart.allCases.forEach { p in self.save(p,self[p]) }
    }
    public func update() {
        self.reset()
        ViewPart.allCases.forEach { p in
            if let v = self.load(p) { self[p]=v }
        }
    }
    public func has(_ p : ViewPart) -> Bool { values[p] != nil }
    public func makeIterator() -> Iterator { values.makeIterator() }
    public func reset() { self.values.removeAll() }
    
    public static func defaults() -> DimensionSetterProtocol { ViewPartDimensions() }
}




