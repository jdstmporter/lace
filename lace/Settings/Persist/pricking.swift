//
//  Serialise.swift
//  lace
//
//  Created by Julian Porter on 14/04/2022.
//

import Foundation
import BitArray

enum PrickingError : BaseError {
    case PointOutsideArea
    case CannotFindPricking
}

enum HistoryActions {
    case Void
    case Pin(_ : GridPoint)
    case Line(_ : ScreenLine)
}

class PrickingSpec {
    public private(set) var name : String = "Pricking"
    public private(set) var pricking : Pricking?
    
    public var width : Int32 { pricking?.width ?? 1 }
    public var height : Int32 { pricking?.height ?? 1 }
    public var kind : LaceKind { pricking?.kind ?? .Custom }
    
    
    init() {}
    init(pricking: Pricking?) {
        self.name=pricking?.name ?? "Pricking"
        self.pricking=pricking
    }
    convenience init(name: String) {
        let pricking = try? Pricking.load(name)
        self.init(pricking: pricking)
    }
    convenience init(url: URL) {
        self.init(name: url.lastPathComponent)
    }
    
    func save() {
        do { try self.pricking?.save() }
        catch {}
    }
    
    func reset() {
        self.name="Pricking"
        self.pricking=nil
    }
}
class PrickingManager {
    static var prickings : [Pricking] = []
    static var changed : [String:Bool] = [:]
    
    static func load() {
        let paths=FileService.enumerate(as: Pricking.self)
        self.prickings = paths.compactMap { try? Pricking.load($0.lastPathComponent) }
    }
    
    static func save() {
        self.prickings.forEach { pricking in
            if self.changed[pricking.name]==true {
                do {
                    try pricking.save()
                    self.changed[pricking.name]=false
                }
                catch {}
            }
        }
    }
    
    
    
    
    static subscript(_ name : String) -> Pricking? {
        get { self.prickings.first { $0.name==name } }
        set {
            guard let pricking=newValue, pricking.name==name else { return }
            if let idx=(self.prickings.firstIndex { $0.name==name}) { self.prickings[idx]=pricking }
            else { self.prickings.append(pricking) }
            self.changed[name]=true
        }
    }

    static func has(name: String) -> Bool { self[name] != nil }
    static func del(name: String) {
        guard let pricking=self[name] else { return }
        do {
            try pricking.del()
            self.prickings.removeAll { $0.name==name }
            self.changed.removeValue(forKey: name)
        }
        catch {}
    }
    
}



struct Pricking : Storable {
    
    var index : Int = 0
    
    var grid : Grid
    var lines : Lines
    var scale : Double = 1.0
    
    
    var name : String
    var kind : LaceKind
    
    var history : [HistoryActions] = []
    
    // exclude history from persistance
    
    enum CodingKeys : CodingKey {
        case grid
        case lines
        case kind
        case scale
        case name
    }
    
    init(name : String="Pricking", size: GridSize,kind: LaceKind = .Custom) {
        self.name=name
        self.grid=Grid(size: size)
        self.lines=Lines()
        self.kind=kind
        self.scale=1.0
        self.index=0
    }
    
    init(name : String = "Pricking", width: Int32 = 1, height : Int32 = 1, kind: LaceKind = .Custom) {
        self.init(name: name, size: GridSize(width,height),kind: kind)
        
    }
    init(name: String,kind: LaceKind,grid: Grid) {
        self.init(name: name, size: grid.size, kind: kind)
        self.grid=grid
    }
 
    var size : GridSize { self.grid.size }
    var width : Int32 { self.grid.width }
    var height : Int32 { self.grid.height }
    
    
    var converter : Convert { Convert(scale) }
    func check(_ p : NSPoint) -> Bool { grid.check(Convert(scale).nearest(p)) }
    
    func nearestPoint(to point: NSPoint) throws -> GridPoint {
        let p = converter.nearest(point)
        guard grid.check(p) else { throw PrickingError.PointOutsideArea }
        return p
    }
    
    func nearestPoint(to point: NSPoint, distance : inout Double) throws -> GridPoint {
        let p = try nearestPoint(to: point)
        let pos = converter.pos(p)
        distance = hypot(pos.x-point.x,pos.y-point.y)
        return p
    }
    
    func snap(point: NSPoint) throws -> NSPoint {
        let p = try nearestPoint(to: point)
        return converter.pos(p)
    }
    
    func snap(line: ScreenLine) -> ScreenLine {
        let gr = line.asGridLine(self)
        return ScreenLine(pricking: self,line: gr)
    }
    func snap(_ from: NSPoint,_ to: NSPoint) -> ScreenLine {
        let gr = ScreenLine(from,to).asGridLine(self)
        return ScreenLine(pricking: self,line: gr)
    }
    func snap(_ p : NSPoint) -> GridPoint { converter.nearest(p) }
    
    mutating func append(_ line : ScreenLine) {
        lines.append(self, line)
        self.history.append(.Line(line))
    }
    mutating func append(_ line : GridLine) {
        lines.append(line)
    }
    mutating func append(_ point : GridPoint) {
        self.grid.flip(point)
        self.history.append(.Pin(point))
    }
    
    mutating func clearHistory() {
        self.history.removeAll()
    }
    
    mutating func undo() {
        guard let action=self.history.last else { return }
        switch action {
        case .Pin(let p):
            self.grid.flip(p)
        case .Line(let l):
            self.lines.append(self,l)
        default:
            break
        }
        self.history.removeLast()
    }
    
    mutating func flip(_ p : GridPoint) { grid.flip(p) }
    mutating func reset() { grid.reset() }
    public subscript(_ x : Int32, _ y : Int32) -> Bool {
        get { self.grid[x,y] }
        set(v) { self.grid[x,y]=v }
    }
    
    func asScreenLine(_ line : GridLine) -> ScreenLine { ScreenLine(pricking: self, line: line) }
    
    
    
}







