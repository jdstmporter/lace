//
//  ViewBase.swift
//  lace
//
//  Created by Julian Porter on 02/04/2022.
//

import Foundation
import Cocoa


extension NSView {
    var width: Double { self.bounds.width }
    var height : Double { self.bounds.height }
    
    @IBInspectable var backgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {return nil}
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
    
    func clear() {
        let bg = backgroundColor ?? .white
        bg.setFill()
        let path = NSBezierPath(rect: bounds)
        path.fill()
    }
}



class ViewBase : NSView, MouseHandler {
    
    var mainTracker : NSTrackingArea?
    var needsTrackerUpdate : Bool = false
    
    func initialise() {
        needsTrackerUpdate=true
    }
    
    // Draweing functions
    
    @IBInspectable var foregroundColor: NSColor = .black {
        didSet {
            self.touch()
        }
    }
    
    func invert(_ p : NSPoint) -> NSPoint {
        NSPoint(x: p.x, y: height-1-p.y)
    }
    func invert(_ l : Line) -> Line {
        Line(invert(l.start), invert(l.end))
    }
    
    func point(_ p : NSPoint, radius: Double, colour: NSColor? = nil) {
        let fg=colour ?? foregroundColor
        fg.setFill()
        let yy=height-1-p.y
        let rect = NSRect(x: p.x-radius, y: yy-radius, width: 2*radius, height: 2*radius)
        let path = NSBezierPath(ovalIn: rect)
        path.fill()
    }
    
    // resize handler
    
    override func updateTrackingAreas() {
        if let m=self.mainTracker { self.removeTrackingArea(m) }
        
        let mt = NSTrackingArea(rect: self.bounds,
                                options:[.mouseEnteredAndExited,.mouseMoved,.activeInKeyWindow],
                                owner: self)
        self.addTrackingArea(mt)
        self.mainTracker=mt
    }
    
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        self.needsTrackerUpdate=true
        self.touch()
        
    }
    
    
    
    
    
    

    
    // mouse handlers
    
    func pos(_ event : NSEvent) -> NSPoint {
        let loc = event.locationInWindow
        let p = self.convert(loc, from: nil)
        return NSPoint(x: p.x, y: self.height-1-p.y)
    }
    
    
    struct MouseDown {
        let time : Date
        let position: NSPoint
        
        init(_ pos : NSPoint) {
            position=pos
            time=Date.now
        }
        
        func distance(_ p : NSPoint) -> Double {
            hypot(position.x-p.x,position.y-p.y)
        }
        func interval() -> Double { -time.timeIntervalSinceNow }
        
    }
    
    var wasAcceptingMouseEvents : Bool = false
    var mouseState : MouseDown? = nil
    var enableDrag : Bool = false
    var lastPoint : NSPoint? = nil
 
    
    // Lace Handler methods
    func didClick(_ at : NSPoint) {}
    func didDrag(_ from : NSPoint,_ to : NSPoint) {}
    func didCancel() {}
    func didMove(_ p : NSPoint) {}
    
    func isDragging(_ from : NSPoint,_ to : NSPoint) {}
    
    func locationIsValid(_ at: NSPoint) -> Bool { true }
    func shouldMoveMouse(_ from: NSPoint) -> NSPoint {from }
    
    
    
  
 
    
    
    override func mouseDown(with event: NSEvent) {
        let p=self.shouldMoveMouse(self.pos(event))
        let valid=self.locationIsValid(p)
        self.mouseState=(valid) ? MouseDown(p) : nil
        self.lastPoint = self.mouseState?.position
    }
    
    
    override func mouseUp(with event: NSEvent) {
        guard let down = mouseState else { return }
        let p=self.shouldMoveMouse(self.pos(event))
        if down.interval() < 0.5 && down.distance(p) < 10 {
            self.didClick(down.position)
            syslog.debug("CLICK!")
        }
        else if down.distance(p)>10 {
            self.didDrag(down.position,p)
            syslog.debug("DRAG!")
        }
        self.mouseState=nil
        self.lastPoint=nil
        self.enableDrag=false

    }
    
    
    
    override func mouseDragged(with event: NSEvent) {
        guard let down = mouseState else { return }
        let p=self.shouldMoveMouse(self.pos(event))
        if down.distance(p) > 10 {
            if self.locationIsValid(p) { self.lastPoint=p }
            if let l=self.lastPoint { self.isDragging(down.position,l) }
        }
        
    }
    
    override func rightMouseDown(with event: NSEvent) {  }
    override func rightMouseUp(with event: NSEvent) {  }
    override func mouseMoved(with event: NSEvent) {
        let p=self.pos(event)
        self.didMove(p)
    }
    
    override func mouseExited(with event: NSEvent) {
        debugPrint("Exit")
        window?.acceptsMouseMovedEvents=wasAcceptingMouseEvents
        self.mouseState=nil
        self.didCancel()
 
    }
    override func mouseEntered(with event: NSEvent) {
        debugPrint("Enter")
        wasAcceptingMouseEvents=window?.acceptsMouseMovedEvents ?? false
        window?.acceptsMouseMovedEvents=true
        window?.makeFirstResponder(self)
        self.mouseState=nil
    }
    
    func touch() {
        DispatchQueue.main.async { self.needsDisplay=true }
    }
    
}

