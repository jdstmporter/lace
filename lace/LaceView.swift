//
//  LaceView.swift
//  lace
//
//  Created by Julian Porter on 01/04/2022.
//

import Foundation
import Cocoa



protocol MouseHandler {
    func didClick(_ : NSPoint)
    func didDrag(_ from: NSPoint,_ to: NSPoint)
    func didCancel()
    
    func isDragging(_ from: NSPoint,_ to: NSPoint)
    
    func locationIsValid(_ : NSPoint) -> Bool
    func shouldMoveMouse(_ : NSPoint) -> NSPoint
}




class LaceView : ViewBase {
    
    //var grid : Grid = Grid(width: 1, height: 1)
    //var lines : Lines = Lines()
    var spacing : Double = 1.0
    var mouseEnabled : Bool = true
    var mouseToGrid : Bool = false
    
    var pricking : Pricking = Pricking()
    
    
    func posFor(x: Int, y: Int) -> NSPoint {
        let yy=Double(y)
        let yf=Double(y%2)/2.0
        let xx = Double(x)
        let yPos = (yy+1)*spacing
        let xPos = (xx+yf+1)*spacing
        return NSPoint(x: xPos, y: yPos)
    }
    
    

    
    func radiusFor(_ x : Int, _ y : Int) -> Double {
        pricking.grid[x,y] ? 5 : 1
    }
    
    static let MaxWidth : Double = 50.0
    static let MaxHeight : Double = 50.0
    //var startP : NSPoint?
    //var endP : NSPoint?
    var line : Line?
    
    func setSize(width: Int,height: Int) {
        DispatchQueue.main.async {
            self.pricking=Pricking(width,height)
            self.needsDisplay=true
        }
    }
    
    func getScaling() {
        let size = self.bounds.size
        let xs = size.width/(LaceView.MaxWidth+2.0)
        let ys = size.height/(LaceView.MaxHeight+2.0)
        //spacing = Swift.max(xs,ys)
        pricking.grid.scale = Swift.max(xs,ys)
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.clear()
        
        self.getScaling()
        
        pricking.grid.yRange.forEach { y in
            pricking.grid.xRange.forEach { x in
                let radius = self.radiusFor(x,y)
                let p = pricking.grid.pos(x, y)
                point(p.x,p.y,radius)
            }
        }
        
        pricking.lines.forEach { line in
            foregroundColor.setStroke()
            let l = invert(pricking.asScreenLine(line)) // invert(Line(grid: pricking.grid, line: line))
            print("\(line) : \(l)")
            l.path.stroke()
        }
        
        if let line=self.line {
            foregroundColor.setStroke()
            invert(line).path.stroke()
        }
        
        //if let s=startP, let e=endP {
        //    let path=NSBezierPath()
        //    path.move(to: invert(s))
        //    path.line(to: invert(e))
        //    foregroundColor.setStroke()
        //    path.stroke()
        //}
    }
    
    
    
    override func didClick(_ at: NSPoint) {
        do {
            let p = try pricking.nearestPoint(to: at)
            print("Picked \(p)")
            pricking.grid.flip(p)
            self.touch()
        }
        catch {}
    }
    
    func LocationIsValid(_ at: NSPoint) -> Bool { pricking.grid.check(at) }
    
    override func didDrag(_ from: NSPoint, _ to: NSPoint) {
        guard let l=line else { return }
        print("Appending \(l)")
        pricking.append(l)
        //startP=nil
        //endP=nil
        line=nil
        self.touch()
    }
    
    override func didCancel() {
        //startP=nil
        //endP=nil
        line=nil
        self.touch()
    }
    
    override func isDragging(_ from: NSPoint, _ to: NSPoint) {
        line=Line(from,to)
        //startP=from
        //endP=to
        self.touch()
    }
    
    override func shouldMoveMouse(_ from: NSPoint) -> NSPoint {
        guard mouseToGrid else { return from }
        return pricking.grid.nearestPoint(from)
    }
    
    
}
