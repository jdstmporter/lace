//
//  Serialise.swift
//  lace
//
//  Created by Julian Porter on 14/04/2022.
//

import Foundation

enum PrickingError : Error {
    case PointOutsideArea
    case CannotFindPricking
}

struct Pricking : Codable {
    let grid : Grid
    let lines : Lines
    
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
    
    static func load(json: Data) throws -> Pricking  {
        let decoder=JSONDecoder()
        return try decoder.decode(Pricking.self, from: json)
    }
    
    func json(compact: Bool = false) throws -> Data {
        let encoder=JSONEncoder()
        if !compact { encoder.outputFormatting = .prettyPrinted }
        return try encoder.encode(self)
    }
    
    func nearestPoint(to point: NSPoint) throws -> GridPoint {
        let p = grid.nearest(point)
        guard grid.check(p) else { throw PrickingError.PointOutsideArea }
        return p
    }
    
    func append(_ line : Line) {
        lines.append(grid, line)
    }
    
    func asScreenLine(_ line : GridLine) -> Line { Line(grid: grid, line: line) }
    
    
    
}


