//
//  colourParts.swift
//  lace
//
//  Created by Julian Porter on 10/09/2022.
//
/*
import AppKit



protocol ColourSetterProtocol {
    subscript(_: ViewPart) -> NSColor {get}
    
    func update()
    mutating func copy(_ o : ColourSetterProtocol)
}

protocol ColourSetterProtocol2 {
    subscript(_: ViewPart) -> NSColor {get}
    
    //func get(_ : ViewPart) -> Double
    //func set(_: ViewPart,_ : Double)
    func reload()
    func revert()
    func commit()
}



class ViewPartsColoursTransient : ColourSetterProtocol {
    
    typealias Container=[ViewPart:NSColor]
    typealias Iterator = Container.Iterator
    private var values : Container = [:]
    
    public init() { self.update() }
    public init(copy: ColourSetterProtocol) {
        self.copy(copy)
    }
    
    private func defaultValue(_ p : ViewPart) -> NSColor { (p == .Background) ? ViewPartColours.White : ViewPartColours.Black }
    
    subscript(_ p: ViewPart) -> NSColor {
        get { self.values[p] ?? defaultValue(p) }
        set { self.values[p] = newValue }
    }
    
    func copy(_ o: ColourSetterProtocol) {
        self.values.removeAll()
        ViewPart.allCases.forEach { self.values[$0] = o[$0] }
    }
    func update() {  }
    
    func commit() throws {
        try ViewPartColours(copy: self).commit()
    }
    
    static func empty() -> ColourSetterProtocol { ViewPartsColoursTransient() }
    static func defaults() -> ColourSetterProtocol { ViewPartsColoursTransient(copy: ViewPartColours.defaults()) }
    
}

class ViewPartColours : Sequence, ColourSetterProtocol {
    static let PREFIX = "Colours-"
    
    typealias Container=[ViewPart:NSColor]
    typealias Iterator = Container.Iterator
    private var values : Container = [:]
    
    static var White : NSColor { .white.deviceRGB }
    static var Black : NSColor { .black.deviceRGB }
    
    public init() { self.update() }
    public init(copy: ColourSetterProtocol) {
        self.copy(copy)
    }
    
    public var colourSpace : CGColorSpace { CGColorSpaceCreateDeviceRGB() }
    
    private func defaultValue(_ p : ViewPart) -> NSColor {
        (p == .Background) ? ViewPartColours.White : ViewPartColours.Black
    }
    private func key(_ p : ViewPart) -> String { "\(ViewPartColours.PREFIX)\(p)" }
    public func load(_ p : ViewPart) throws -> NSColor  { try Defaults.colour(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : NSColor) throws { try Defaults.setColour(value: v,forKey:key(p)) }
    
    public subscript(_ p : ViewPart) -> NSColor {
        get { values[p] ?? defaultValue(p) }
        set { values[p] = newValue.deviceRGB }
    }
    public subscript(cg: ViewPart) -> CGColor { self[cg].cgColor }
    
    public func has(_ p : ViewPart) -> Bool { values[p] != nil }
    func makeIterator() -> Iterator { values.makeIterator() }
    
    public func touch() {
        ViewPart.allCases.forEach { p in
            if let c=values[p]?.deviceRGB { values[p]=c }
        }
    }
    public func reset() {
        self.values.removeAll()
    }
    
    public func commit() throws {
        try ViewPart.allCases.forEach { p in try self.save(p, self[p]) }
    }
    
    func copy(_ o: ColourSetterProtocol) {
        self.values.removeAll()
        ViewPart.allCases.forEach { self.values[$0] = o[$0] }
    }
    public func update() {
        self.reset()
        ViewPart.allCases.forEach { p in
            do { self[p]=try self.load(p) }
            catch(let e) {
                syslog.error("Error loading: \(e) - reverting to default")
            }
        }
    }
    
    public static func defaults() -> ColourSetterProtocol { ViewPartColours() }
}


class ViewColours : ColourSetterProtocol2 {
    static let PREFIX = "Colours-"
    
    typealias Container=[ViewPart:NSColor]
    typealias Iterator = Container.Iterator
    private var values : Container = [:]
    private var temps : Container = [:]
    private var mode : LaceViewMode
    
    static var White : NSColor { .white.deviceRGB }
    static var Black : NSColor { .black.deviceRGB }
    
    private func key(_ p : ViewPart) -> String { "\(ViewColours.PREFIX)\(p)" }
    public func load(_ p : ViewPart) -> NSColor?  { try? Defaults.colour(forKey: key(p))}
    public func save(_ p : ViewPart,_ v : NSColor) { try? Defaults.setColour(value: v,forKey:key(p)) }
    public func has(_ p : ViewPart) -> Bool { values[p] != nil }
    
    public init(mode : LaceViewMode = .Permanent) {
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
    
    
    private func defaultValue(_ p : ViewPart) -> NSColor {
        (p == .Background) ? ViewPartColours.White : ViewPartColours.Black
    }
    private func value(_ p : ViewPart) -> NSColor { self.values[p] ?? defaultValue(p) }
    
    subscript(_ p: ViewPart) -> NSColor {
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
    
    public static func defaults() -> ViewColours { ViewColours() }
}
 
 */


