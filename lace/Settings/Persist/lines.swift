//
//  lines.swift
//  lace
//
//  Created by Julian Porter on 26/12/2022.
//

import Foundation

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
    //init(_ grid : Grid,_ line : ScreenLine) {
    //    self.start=grid.nearest(line.start)
    //    self.end=grid.nearest(line.end)
    //}
    
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
