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


enum LaceViewMode {
    case Temporary
    case Permanent
}

protocol LaceViewDelegate {
    typealias ViewData = (colour: NSColor,dimension: Double)
    
    var dimensions : ViewDimensions { get set }
    var colours : ViewColours { get set }
    var mode : LaceViewMode { get set }
    
    subscript(_ v : ViewPart) -> ViewData { get }
    mutating func set(_ v : ViewPart, _ c : NSColor)
    mutating func set(_ v : ViewPart, _ d : Double)
    
    mutating func has(_ v : ViewPart) -> (colour: Bool,dimension: Bool)
    
    mutating func reload()
    mutating func commit()
    mutating func revert()
}

extension LaceViewDelegate {
    
    var mode : LaceViewMode {
        get { dimensions.mode }
        set {
            dimensions.mode=newValue
            colours.mode=newValue
        }
    }
    
    mutating func reload() {
        self.dimensions.reload()
        self.colours.reload()
    }
    mutating func commit() {
        self.dimensions.commit()
        self.colours.commit()
    }
    mutating func revert() {
        self.dimensions.revert()
        self.colours.revert()
    }
    
    subscript(_ v : ViewPart) -> ViewData {
        let c=self.colours[v]
        let d=self.dimensions[v]
        return ViewData(colour: c,dimension: d)
    }
    mutating func set(_ v : ViewPart, _ c : NSColor) { self.colours[v]=c }
    mutating func set(_ v : ViewPart, _ d : Double) { self.dimensions[v]=d }
    
    mutating func has(_ v : ViewPart) -> (colour: Bool,dimension: Bool) {
        (colour: self.colours.has(v), dimension: self.dimensions.has(v))
    }
}

class ViewDelegate : LaceViewDelegate {
    var dimensions : ViewDimensions
    var colours : ViewColours
    
    init(mode : LaceViewMode = .Permanent) {
        self.dimensions=ViewDimensions(mode: mode)
        self.colours=ViewColours(mode: mode)
    }
}

class LaceView : ViewBase {
    
    //var grid : Grid = Grid(width: 1, height: 1)
    //var lines : Lines = Lines()
    var spacing : Double = 1.0
    var mouseEnabled : Bool = true
    var mouseToGrid : Bool = false
    
    var delegate : LaceViewDelegate = ViewDelegate() { didSet { self.reload() }}
    var pricking : Pricking = Pricking()
    
    func reload() {
        self.delegate.reload()
        self.backgroundColor = self.delegate[.Background].colour
        self.touch()
    }
    
    func posFor(x: Int, y: Int) -> NSPoint {
        let yy=Double(y)
        let yf=Double(y%2)/2.0
        let xx = Double(x)
        let yPos = (yy+1)*spacing
        let xPos = (xx+yf+1)*spacing
        return NSPoint(x: xPos, y: yPos)
    }
    
     var MaxWidth : Double = 50.0
     var MaxHeight : Double = 50.0
    
    
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
        let xs = size.width/(self.MaxWidth+2.0)
        let ys = size.height/(self.MaxHeight+2.0)
        //spacing = Swift.max(xs,ys)
        pricking.grid.scale = Swift.max(xs,ys)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.clear()
        
        self.getScaling()
        
        pricking.grid.yRange.forEach { y in
            pricking.grid.xRange.forEach { x in
                let isPin = pricking.grid[x,y]
                let pinData = self.delegate[isPin ? .Pin : .Grid]
                let radius = pinData.dimension
                let fg : NSColor = pinData.colour
                let p = pricking.grid.pos(x, y)
                point(p,radius: radius,colour: fg)
            }
        }
        
        pricking.lines.forEach { line in
            self.delegate[.Line].colour.setStroke()
            let l = invert(pricking.asScreenLine(line)) // invert(Line(grid: pricking.grid, line: line))
            syslog.debug("\(line) : \(l)")
            let p=l.path
            p.lineWidth=self.delegate[.Line].dimension
            p.stroke()
        }
        
        if let line=self.line {
            self.delegate[.Line].colour.setStroke()
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
            syslog.debug("Picked \(p)")
            pricking.grid.flip(p)
            self.touch()
        }
        catch {}
    }
    
    func LocationIsValid(_ at: NSPoint) -> Bool { pricking.grid.check(at) }
    
    override func didDrag(_ from: NSPoint, _ to: NSPoint) {
        guard let l=line else { return }
        syslog.debug("Appending \(l)")
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
