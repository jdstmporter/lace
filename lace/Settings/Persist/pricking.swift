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

struct Pricking : Codable {
    let grid : Grid
    let lines : Lines
    
    var history : [HistoryActions] = []
    
    enum CodingKeys : String, CodingKey {
        case grid
        case lines
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.grid = try c.decode(Grid.self,forKey: .grid)
        self.lines = try c.decode(Lines.self,forKey: .lines)
    }
    
    func encode(to encoder: Encoder) throws {
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.grid,forKey : .grid)
        try c.encode(self.lines,forKey : .lines)
    }
    
    init(_ width: Int = 1,_ height: Int = 1) {
        self.grid = Grid(width: width, height: height)
        self.lines = Lines()
    }
    
    init(grid: Grid,lines: Lines) {
        self.grid=grid
        self.lines=lines
    }
    
    
    
    func nearestPoint(to point: NSPoint) throws -> GridPoint {
        let p = grid.converter.nearest(point)
        guard grid.check(p) else { throw PrickingError.PointOutsideArea }
        return p
    }
    
    func nearestPoint(to point: NSPoint, distance : inout Double) throws -> GridPoint {
        let p = try nearestPoint(to: point)
        let pos = grid.converter.pos(p)
        distance = hypot(pos.x-point.x,pos.y-point.y)
        return p
    }
    
    func snap(point: NSPoint) throws -> NSPoint {
        let p = try nearestPoint(to: point)
        return grid.converter.pos(p)
    }
    
    func snap(line: ScreenLine) -> ScreenLine {
        let gr = line.asGridLine(grid)
        return ScreenLine(grid: grid,line: gr)
    }
    func snap(_ from: NSPoint,_ to: NSPoint) -> ScreenLine {
        let gr = ScreenLine(from,to).asGridLine(grid)
        return ScreenLine(grid: grid,line: gr)
    }
    func snap(_ p : NSPoint) -> GridPoint { grid.converter.nearest(p) }
    
    mutating func append(_ line : ScreenLine) {
        lines.append(grid, line)
        self.history.append(.Line(line))
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
            self.lines.append(self.grid,l)
        default:
            break
        }
        self.history.removeLast()
    }
    
    func asScreenLine(_ line : GridLine) -> ScreenLine { ScreenLine(grid: grid, line: line) }
    
    
    
}







