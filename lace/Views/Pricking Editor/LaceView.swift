//
//  LaceView.swift
//  lace
//
//  Created by Julian Porter on 01/04/2022.
//

import Foundation
import Cocoa
import Atomics


protocol MouseHandler {
    func didClick(_ : NSPoint)
    func didMove(_ : NSPoint)
    func didDrag(_ from: NSPoint,_ to: NSPoint)
    func didCancel()
    
    func isDragging(_ from: NSPoint,_ to: NSPoint)
    
    func locationIsValid(_ : NSPoint) -> Bool
    func shouldMoveMouse(_ : NSPoint) -> NSPoint
}

/*
enum LaceViewMode {
    case Temporary
    case Permanent
}

protocol LaceViewDelegate {
    associatedtype Dims where Dims : P, Dims.Element==Double
    associatedtype Cols where Cols : P, Cols.Element==NSColor
    
    typealias ViewData = (colour: NSColor,dimension: Double)
    var dimensions : Dims { get set }
    var colours : Cols { get set }
    
    
    subscript(_ v : ViewPart) -> ViewData { get }
    
    mutating func has(_ v : ViewPart) -> (colour: Bool,dimension: Bool)
    
    mutating func reload()
    mutating func reset()
}

extension LaceViewDelegate {
    
    
    
    mutating func reload() {
        self.dimensions.reload()
        self.colours.reload()
    }

    mutating func reset() {
        self.dimensions.reset()
        self.colours.reset()
    }
    
    subscript(_ v : ViewPart) -> ViewData {
        let c=self.colours[v]
        let d=self.dimensions[v]
        return ViewData(colour: c,dimension: d)
    }
    mutating func has(_ v : ViewPart) -> (colour: Bool,dimension: Bool) {
        (colour: self.colours.has(v), dimension: self.dimensions.has(v))
    }
}

protocol LaceViewDelegateMutable : LaceViewDelegate
    where Dims : PMutable, Dims.Element == Double, Cols : PMutable, Cols.Element == NSColor {
    mutating func set(_ v : ViewPart, _ c : NSColor)
    mutating func set(_ v : ViewPart, _ d : Double)

    mutating func revert()
    mutating func commit()
}

extension LaceViewDelegateMutable {
    
    mutating func commit() {
        self.dimensions.commit()
        self.colours.commit()
    }
    mutating func revert() {
        self.dimensions.revert()
        self.colours.revert()
    }

    mutating func set(_ v : ViewPart, _ c : NSColor) { self.colours[v]=c }
    mutating func set(_ v : ViewPart, _ d : Double) { self.dimensions[v]=d }
}


class ViewDelegate : LaceViewDelegate {
    
    var dimensions : ViewDimensions
    var colours : ViewColours
    
    init() {
        self.dimensions=ViewDimensions()
        self.colours=ViewColours()
    }
    
    func copy(_ o : ViewDelegateMutable) {
        dimensions.copy(o.dimensions)
        colours.copy(o.colours)
    }
}
 
 

class ViewDelegateMutable : LaceViewDelegateMutable {
    var dimensions: ViewDimensionsMutable
    var colours: ViewColoursMutable

    
    init() {
        self.dimensions=ViewDimensionsMutable()
        self.colours=ViewColoursMutable()
    }
}
 
 */

extension NSRect {
    init(centre: NSPoint, side: Double) {
        self.init(x: centre.x-0.5*side, y: centre.y-0.5*side, width: side, height: side)
    }
}
extension NSBezierPath {
    convenience init(from: NSPoint, to: NSPoint) {
        self.init()
        self.move(to: from)
        self.line(to: to)
    }
    
}

struct ExtendedPoint : CustomStringConvertible {
    var point : NSPoint?
    var raw : NSPoint
    
    init(point: NSPoint,pricking: Pricking) {
        self.raw=point
        self.point=try? pricking.snap(point: point)
    }
    
    init(raw : NSPoint,point: NSPoint) {
        self.raw=raw
        self.point=point
    }
    
    var path : NSBezierPath {
        guard let p=self.point else { return NSBezierPath() }
        return NSBezierPath(ovalIn: NSRect(centre: p,side: 2))
    }
    var extendedPath : [NSBezierPath] {
        var paths = [NSBezierPath(ovalIn: NSRect(centre: raw,side: 8))]
        if let p=self.point {
            let p2=NSBezierPath(from: raw, to: p) //; p2.move(to: raw.start); p2.line(to: line.start)
            let dashes : [CGFloat] = [8.0,2.0]
            p2.setLineDash(dashes, count: 2, phase: 0.0)
            paths.append(p2)
        }
        return paths
    }
    
    var description: String {
        if let p = point { return "\(raw) : \(p)" }
        else { return "\(raw) - N/A" }
    }
    
}

struct ExtendedLine : CustomStringConvertible {
    var line : ScreenLine
    var raw : ScreenLine
    
    
    init(start: NSPoint,end: NSPoint,pricking: Pricking) {
        self.raw=ScreenLine(start, end)
        self.line=pricking.snap(start,end)
    }
    
    init(raw : ScreenLine,line: ScreenLine) {
        self.raw=raw
        self.line=line
    }
    
   
    
    var path : NSBezierPath { line.path }
    var extendedPath : [NSBezierPath] {
        var paths : [NSBezierPath] = []
        paths.append(NSBezierPath(ovalIn: NSRect(centre: raw.start,side: 8)))
        let p2=NSBezierPath(from: raw.start, to: line.start) //; p2.move(to: raw.start); p2.line(to: line.start)
        let dashes : [CGFloat] = [8.0,2.0]
        p2.setLineDash(dashes, count: 2, phase: 0.0)
        paths.append(p2)
        let p3=NSBezierPath(from:line.start,to:line.end) //; p3.move(to: line.start); p3.line(to: line.end)
        paths.append(p3)
        let p4=NSBezierPath(from:line.end,to:raw.end) //; p4.move(to: line.end); p4.line(to: raw.end)
        p4.setLineDash(dashes, count: 2, phase: 0.0)
        paths.append(p4)
        paths.append(NSBezierPath(ovalIn: NSRect(centre: raw.end,side: 8)))
        return paths
    }
    
    var description: String { "\(raw) : \(line)"}
    
}

class AtomicFlagOld {
    
    private static var queue = DispatchQueue(label: "AtomicFlag",qos: .userInteractive)
    private var _flag : Bool = false
    
    func set() { Self.queue.sync { [self] in self._flag=true }}
    func clear() { Self.queue.sync { [self] in self._flag=false }}
    func test() -> Bool { Self.queue.sync { [self] in self._flag }}
    func testAndClear() -> Bool {
        Self.queue.sync { [self] in
            let v = self._flag
            self._flag=false
            return v
        }
    }
}

class AtomicFlag {
    private var _flag : ManagedAtomic<Bool> = ManagedAtomic<Bool>(false)
    
    func set() { _flag.store(true, ordering: .relaxed) }
    func clear() { _flag.store(false, ordering: .relaxed) }
    func test() -> Bool { _flag.load(ordering: .relaxed) }
    func testAndClear() -> Bool { _flag.loadThenLogicalAnd(with: false, ordering: .relaxed) }
}


class LaceView : ViewBase {
    
    var spacing : Double = 1.0
    var mouseEnabled : Bool = true
    var mouseToGrid : Bool = false
    //var delegateLoaded : Bool = false
    
    var tracker : [NSTrackingArea] = []
    
    //public private(set) var colours : ViewColours?
    //public private(set) var dims : ViewDimensions?
    public var dims : ViewDimensions = ViewDimensions()
    public var colours : ViewColours = ViewColours()
    
    var pricking : Pricking = Pricking()

    
    func reload() {
        //guard let colours=self.colours else { return }
        self.backgroundColor = colours[.Background]
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

    
    var spacingInMetres : CGFloat = 0.01 // 10mm
    var liner : ExtendedLine?
    
    func setSize(width: Int,height: Int) { self.setSize(GridSize(width,height)) }
    func setSize(_ size: GridSize) {
        DispatchQueue.main.async {
            self.pricking=Pricking(name: "", size: size)
            self.needsTrackerUpdate=true
            self.needsDisplay=true
        }
    }
    
    func getScaling() {
        pricking.scale = Display.current.convertToPixels(metres: self.spacingInMetres)
    }
    
    func setSpacing(inMetres: CGFloat) {
        self.spacingInMetres=inMetres
        self.getScaling()
        self.needsTrackerUpdate=true
        self.touch()
    }
    
    /// drawing functions
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
      
        
        self.tracker.forEach { self.removeTrackingArea($0) }
        self.tracker.removeAll()
        
        let conv=pricking.converter
        

        pricking.grid.yRange.forEach { y in
            pricking.grid.xRange.forEach { x in
                let p = invert(conv.pos(x, y))
                let r = NSRect(centre: p, side: pricking.scale)
                syslog.announce("(\(x),\(y)) -|> \(r)   [\(pricking.scale)]")
                let area = NSTrackingArea(rect: r,
                                          options: [.mouseEnteredAndExited,.activeInKeyWindow],
                                          owner: self,
                                          userInfo: ["x" : x, "y" : y])
                self.addTrackingArea(area)
                self.tracker.append(area)
            }
        }
        self.pricking.grid.updateTracking(view: self)
        self.needsTrackerUpdate=false
    }
    
    func invert(_ el : ExtendedLine) -> ExtendedLine {
        ExtendedLine(raw: invert(el.raw),line: invert(el.line))
    }

    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        //guard let colours=self.colours else { return } //, let dims=self.dims else { return }
        self.clear()
        
        
        
        self.getScaling()
        if self.needsTrackerUpdate {
            self.updateTrackingAreas()
            self.needsTrackerUpdate=false
        }
        
     
        let conv=pricking.converter
        pricking.grid.yRange.forEach { y in
            pricking.grid.xRange.forEach { x in
                let isPin = pricking[x,y]
                let pinData : ViewPart = isPin ? .Pin : .Grid
                let radius = dims[pinData]
                let fg : NSColor = colours[pinData]
                let p = conv.pos(x, y)
                point(p,radius: radius,colour: fg)
            }
        }
        
        let stroke=colours[.Line]
        let width=dims[.Line]
        pricking.lines.forEach { line in
            stroke.setStroke()
            let l = invert(pricking.asScreenLine(line)) // invert(Line(grid: pricking.grid, line: line))
            syslog.debug("\(line) : \(l)")
            let p=l.path
            p.lineWidth=width
            p.stroke()
        }
        
        if let liner=self.liner {
            stroke.setStroke()
            invert(liner).extendedPath.forEach { $0.stroke() }
            //invert(rawLine!).path.stroke()
        }
        
        //if let s=startP, let e=endP {
        //    let path=NSBezierPath()
        //    path.move(to: invert(s))
        //    path.line(to: invert(e))
        //    foregroundColor.setStroke()
        //    path.stroke()
        //}
    }
    
    /// Mouse stuff
    
    
    override func didClick(_ at: NSPoint) {
        do {
            let p = try pricking.nearestPoint(to: at)
            syslog.debug("Picked \(p)")
            pricking.append(p)
            self.touch()
        }
        catch {}
    }
    
    func LocationIsValid(_ at: NSPoint) -> Bool { pricking.check(at) }
    
    override func didDrag(_ from: NSPoint, _ to: NSPoint) {
        guard let l=liner?.line else { return }
        syslog.debug("Appending \(l)")
        pricking.append(l)
        //startP=nil
        //endP=nil
        liner=nil
        self.touch()
    }
    
    override func didCancel() {
        //startP=nil
        //endP=nil
        liner=nil
        //rawLine=nil
        self.touch()
    }
    
    override func isDragging(_ from: NSPoint, _ to: NSPoint) {
        liner=ExtendedLine(start: from, end: to, pricking: pricking)
        if let l=liner { syslog.debug("Appending \(l)") }
        //line=pricking.snap(from,to)
        //rawLine=Line(from,to)
        //startP=from
        //endP=to
        self.touch()
    }
    
    override func shouldMoveMouse(_ from: NSPoint) -> NSPoint {
        guard mouseToGrid else { return from }
        return pricking.converter.nearestPoint(from)
    }
    
    func trackerCoordinate(_ event : NSEvent) -> GridPoint? {
        guard let info=event.trackingArea?.userInfo else { return nil }
        guard let x=info["x"] as? Int, let y=info["y"] as? Int else { return nil }
        return GridPoint(x, y)
    }
    
    
    
    
    override func mouseEntered(with event: NSEvent) {
        syslog.announce("Tracking areas = \(self.tracker.count)")
        if trackerCoordinate(event)==nil { super.mouseEntered(with: event) }
    }
    
    override func mouseExited(with event: NSEvent) {
        if trackerCoordinate(event)==nil { super.mouseExited(with: event) }
    }
    
}
