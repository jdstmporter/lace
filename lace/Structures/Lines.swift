//
//  Lines.swift
//  lace
//
//  Created by Julian Porter on 10/04/2022.
//

import Foundation
import Cocoa


struct GridPoint : CustomStringConvertible, Equatable, Codable {
    let x : Int
    let y : Int
    
    enum CodingKeys : String, CodingKey {
        case x
        case y
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.x = try c.decode(Int.self,forKey: .x)
        self.y = try c.decode(Int.self,forKey: .y)
    }
    
    func encode(to encoder: Encoder) throws {
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.x,forKey : .x)
        try c.encode(self.y,forKey : .y)
    }
    
    init(_ x : Int, _ y : Int) {
        self.x=x
        self.y=y
    }
    
    var adjustedX : Double {
        let xx=Double(self.x)
        return (y%2 == 1) ? xx+0.5 : xx
    }
    
    var description: String { " (\(x),\(y))"}
    
    static func==(_ l : GridPoint,_ r : GridPoint) -> Bool {
        l.x==r.x && l.y==r.y
    }
}


    
    
    
    struct GridLine : CustomStringConvertible, Codable {
        let start : GridPoint
        let end : GridPoint
        
        enum CodingKeys : String, CodingKey {
            case start
            case end
        }
        
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.start = try c.decode(GridPoint.self,forKey: .start)
            self.end = try c.decode(GridPoint.self,forKey: .end)
        }
        
        func encode(to encoder: Encoder) throws {
            var c=encoder.container(keyedBy: CodingKeys.self)
            try c.encode(self.start,forKey : .start)
            try c.encode(self.end,forKey : .end)
        }
        
        init(_ start: GridPoint, _ end: GridPoint) {
            self.start=start
            self.end=end
        }
        init(_ grid : Grid,_ line : Line) {
            self.start=grid.nearest(line.start)
            self.end=grid.nearest(line.end)
        }
        
        var gradient : Double {
            let dx=end.adjustedX-start.adjustedX
            guard dx != 0 else { return Double.infinity }
            return Double(end.y-start.y)/dx
        }
        var isGood : Bool { start != end }
        
        var description: String { " \(start) : \(end) [\(gradient)]" }
        
        
        enum Match {
            case SS
            case SE
            case ES
            case EE
            
            case Nil
            
            init(_ l1 : GridLine,_ l2 :GridLine) {
                if l1.start==l2.start { self = .SS }
                else if l1.end==l2.end { self = .EE }
                else if l1.end==l2.start { self = .ES }
                else if l1.start==l2.end { self = .SE }
                else { self = .Nil }
                
            }
        }
        
        static func merge(_ l1 : GridLine,_ l2 :GridLine) -> GridLine? {
            let match = Match(l1,l2)
            switch match {
            case .EE:
                return GridLine(l1.start,l2.start)
            case .SE:
                return GridLine(l1.end,l2.start)
            case .ES:
                return GridLine(l1.start,l2.end)
            case .SS:
                return GridLine(l1.end,l2.end)
            case .Nil:
                return nil
        }
            
    }
    }



struct Line : CustomStringConvertible, Codable {

    let start : NSPoint;
    let end : NSPoint;
    
    enum CodingKeys : String, CodingKey {
        case start
        case end
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.start = try c.decode(NSPoint.self,forKey: .start)
        self.end = try c.decode(NSPoint.self,forKey: .end)
    }
    
    func encode(to encoder: Encoder) throws {
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.start,forKey : .start)
        try c.encode(self.end,forKey : .end)
    }
    
    init(_ start: NSPoint,_ end: NSPoint) {
        self.start=start
        self.end=end
    }
    init(_ start: NSPoint) {
        self.start=start
        self.end=start
    }
    init(grid : Grid,line : GridLine) {
        let l=grid.pos(line)
        self.start=l.start
        self.end=l.end
    }
    var path : NSBezierPath {
        let path=NSBezierPath()
        path.move(to: start)
        path.line(to: end)
        return path
    }
    
    func asGridLine(_ grid : Grid) -> GridLine {
        GridLine(grid,self)
    }
    
    func checkIn(_ grid: Grid) -> Bool {
        grid.check(grid.nearest(start)) && grid.check(grid.nearest(end))
    }
    
    
    var description: String { " \(start) : \(end) " }
    
    
    
}

class Lines : Sequence, Codable {
    typealias Element = GridLine
    typealias Iterator = Array<GridLine>.Iterator
    
    var lines : [GridLine]
    
    enum CodingKeys : String, CodingKey {
        case lines
    }
    
    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.lines = try c.decode([GridLine].self,forKey: .lines)
    }
    
    func encode(to encoder: Encoder) throws {
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.lines,forKey : .lines)
    }
    
    
    init() {
        self.lines=[]
    }
    var count : Int { lines.count }
    
    func append(_ line : GridLine) {
        let grad=line.gradient
        var matched=false
        var newLines : [GridLine] = lines.map { l in
            if !matched && l.gradient==grad {
                if let n1=GridLine.merge(l,line) {
                    matched=true
                    return n1
                }
            }
            return l
        }
        if !matched { newLines.append(line) }
        self.lines = newLines.filter { $0.isGood }
    }
    func append(_ grid : Grid,_ line: Line) {
        let l=line.asGridLine(grid)
        syslog.debug("Appending LINE \(line) : GLINE \(l)")
        self.append(l)
    }
    subscript(_ n : Int) -> GridLine { lines[n] }
    
    func asCoords(_ grid : Grid) -> [Line] { self.lines.map { grid.pos($0) } }
    
    func makeIterator() -> Iterator {
        lines.makeIterator()
    }
 
}
