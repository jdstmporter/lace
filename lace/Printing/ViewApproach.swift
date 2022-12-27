//
//  ViewApproach.swift
//  lace
//
//  Created by Julian Porter on 22/05/2022.
//

import Foundation
import AppKit


class PrintableView : NSImageView {
    
    var pricking : Pricking = Pricking()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.isEditable=true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isEditable=true
    }
    
    func load(pricking: Pricking,spacingInM: Double,dpM : Int) {
        let sc = Double(dpM)*spacingInM
        
        let w = (pricking.grid.width.double+2)*sc
        let h = (pricking.grid.height.double+2)*sc
        
        self.pricking=pricking
        self.bounds = NSRect(x: 0, y: 0, width: w, height: h)
        
        self.pricking.grid.scale = sc
        self.touch()
    }
    
    
    
    func render() -> NSBitmapImageRep? {
        guard let rep=self.bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        self.cacheDisplay(in: bounds, to: rep)
        return rep
    }
    
    
    
    var dimensions = ViewDimensions() {
        didSet {
            self.touch()
        }
    }
 
    var colours = ViewColours() {
        didSet {
            self.backgroundColor = colours[.Background]
            self.touch()
        }
    }
    
    
    
    func touch() {
        DispatchQueue.main.async { self.needsDisplay=true }
    }
    
 
   
    @IBInspectable var foregroundColor: NSColor = .black {
        didSet {
            self.touch()
        }
    }
    
    func invert(_ p : NSPoint) -> NSPoint {
        NSPoint(x: p.x, y: height-1-p.y)
    }
    func invert(_ l : ScreenLine) -> ScreenLine {
        ScreenLine(invert(l.start), invert(l.end))
    }
    
    func point(_ p : NSPoint, radius: Double, colour: NSColor? = nil) {
        let fg=colour ?? foregroundColor
        fg.setFill()
        let yy=height-1-p.y
        let rect = NSRect(x: p.x-radius, y: yy-radius, width: 2*radius, height: 2*radius)
        let path = NSBezierPath(ovalIn: rect)
        path.fill()
    }
    
 
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.clear()
        
        pricking.grid.yRange.forEach { y in
            pricking.grid.xRange.forEach { x in
                let isPin = pricking.grid[x,y]
                let radius = dimensions[isPin ? .Pin : .Grid]
                let fg : NSColor = colours[isPin ? .Pin : .Grid]
                let p = pricking.grid.pos(x, y)
                point(p,radius: radius,colour: fg)
            }
        }
        
        pricking.lines.forEach { line in
            self.colours[.Line].setStroke()
            let l = invert(pricking.asScreenLine(line)) // invert(Line(grid: pricking.grid, line: line))
            syslog.debug("\(line) : \(l)")
            let p=l.path
            p.lineWidth=dimensions[.Line]
            p.stroke()
        }
        
  
    }
    
}
