//
//  Serialise.swift
//  lace
//
//  Created by Julian Porter on 14/04/2022.
//

import Foundation

enum PrickingError : BaseError {
    case PointOutsideArea
    case CannotFindPricking
}

enum HistoryActions {
    case Void
    case Pin(_ : GridPoint)
    case Line(_ : ScreenLine)
}

struct Pricking {
    
    var specification : PrickingSpecification
    
    var grid : Grid
    var lines : Lines
    var scale : Double
    
    
    var name : String { self.specification.name }
    var kind : LaceKind { self.specification.kind }
    
    var history : [HistoryActions] = []
    
    init(_ width: Int = 1,_ height: Int = 1,name : String = "",kind : LaceKind = .Torchon) {
        let spec = PrickingSpecification(name: name, width: width, height: height, kind: kind)
        self.init(spec)
    }
    
    init(grid: Grid,lines: Lines,name : String = "",kind : LaceKind = .Torchon) {
        let spec = PrickingSpecification(name: name, width: grid.width, height: grid.height, kind: kind, grid: grid.data)
        self.init(spec)
    }
    
    init(_ specifier : PrickingSpecification) {
        self.scale = 1.0
        self.specification=specifier
        self.grid=Grid(specifier)
        self.lines=Lines(specifier)
    }
    
    var width : Int { self.grid.width }
    var height : Int { self.grid.height }
    
    
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
    public subscript(_ x : Int, _ y : Int) -> Bool {
        get { self.grid[x,y] }
        set(v) { self.grid[x,y]=v }
    }
    
    func asScreenLine(_ line : GridLine) -> ScreenLine { ScreenLine(pricking: self, line: line) }
    
    
    
}







