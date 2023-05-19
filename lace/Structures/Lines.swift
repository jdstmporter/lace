//
//  Lines.swift
//  lace
//
//  Created by Julian Porter on 10/04/2022.
//

import Foundation
import Cocoa




    
    
    
    


struct ScreenLine : CustomStringConvertible, Codable {

    let start : NSPoint
    let end : NSPoint
    
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
    init(pricking : Pricking,line : GridLine) {
        let conv=pricking.converter
        self.start=conv.pos(line.start)
        self.end=conv.pos(line.end)
    }
    
    var path : NSBezierPath {
        let path=NSBezierPath()
        path.move(to: start)
        path.line(to: end)
        return path
    }
    
    func asGridLine(_ pricking : Pricking) -> GridLine {
        let conv=pricking.converter
        let s=conv.nearest(start)
        let e=conv.nearest(end)
        return GridLine(s,e)
    }
    
    func checkIn(_ pricking : Pricking) -> Bool {
        return pricking.check(start) && pricking.check(end)
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
    
    convenience init(_ specifier : PrickingSpecification) {
        self.init()
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
    func append(_ pricking : Pricking,_ line: ScreenLine) {
        let l=line.asGridLine(pricking)
        syslog.debug("Appending LINE \(line) : GLINE \(l)")
        self.append(l)
    }
    subscript(_ n : Int) -> GridLine { lines[n] }
    
    func asCoords(_ pricking : Pricking) -> [ScreenLine] {
        self.lines.map { ScreenLine(pricking: pricking,line: $0) }
    }
    
    func makeIterator() -> Iterator {
        lines.makeIterator()
    }
 
}
