//
//  CGApproach.swift
//  lace
//
//  Created by Julian Porter on 16/07/2022.
//

import Foundation
import CoreGraphics
import AppKit

class CGPrintable {
    
    
    
    var pricking : Pricking
    let size : NSSize
    let frame : NSRect
    var context : CGContext!
    var colours : ViewColours
    let dimensionScaling : Double
    
    public static var colourSpace : CGColorSpace { CGColorSpaceCreateDeviceRGB() }
    
    init(pricking: Pricking,spacingInMetres spM: Double,dotsPerMetre dpM: Int) {
        
        self.colours = ViewColours(.Defaults)
        
        let sc = Double(dpM)*spM
        
        let w = (pricking.grid.width.double+2)*sc
        let h = (pricking.grid.height.double+2)*sc
        
        self.pricking=pricking
        self.size = NSSize.init(width: w, height: h)
        self.frame = NSRect(origin: NSPoint(), size: self.size)
        self.pricking.grid.scale=sc
        
        let app = NSApplication.shared
        let win = app.mainWindow
        let display = Display(window: win) ?? Display()
        dimensionScaling = Double(dpM)/display.dotsPerMetre
    }
    
    
    
    var dimensions = ViewDimensions(.Defaults) {
        didSet {
            //self.touch()
        }
    }
    
    

    
    func renderCG() -> CGImage? {
        guard let gc = CGContext.init(data: nil, width: self.size.widthI, height: self.size.heightI, bitsPerComponent: 8, bytesPerRow: 0, space: Self.colourSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else { return nil }
        self.context=gc
        self.draw()
        guard let image = self.context.makeImage() else { return nil }
        self.context=nil
        return image
    }
    
    func render() -> NSBitmapImageRep? {
        guard let image = renderCG() else { return nil }
        return NSBitmapImageRep(cgImage: image)
    }
    
    
    
    func invert(_ p : NSPoint) -> NSPoint {
        NSPoint(x: p.x, y: self.size.height-1-p.y)
    }
    func invert(_ l : Line) -> Line {
        Line(invert(l.start), invert(l.end))
    }
    
    func point(_ p : NSPoint, radius: Double, colour: CGColor) {
        let yy=self.size.height-1-p.y
        let rect = NSRect(x: p.x-radius, y: yy-radius, width: 2*radius, height: 2*radius)
        self.context.setFillColor(colour)
        self.context.fillEllipse(in: rect)
    }
    
    func line(_ l : Line) {
        self.context.beginPath()
        self.context.move(to: l.start)
        self.context.addLine(to: l.end)
        self.context.strokePath()
    }
    
    func clear() {
        self.context.setFillColor(self.colours[.Background].cgColor)
        self.context.fill(self.frame)
    }
    
    func draw() {
        self.clear()
        
        self.context.setStrokeColor(self.colours[.Line].cgColor)
        self.context.stroke(NSRect(x: 0, y: 0, width: self.size.width-1, height: self.size.height-1))
        
        pricking.grid.yRange.forEach { y in
            pricking.grid.xRange.forEach { x in
                let isPin = pricking.grid[x,y]
                let radius = dimensions[isPin ? .Pin : .Grid]*self.dimensionScaling
                let fg : CGColor = self.colours[isPin ? .Pin : .Grid].cgColor
                let p = pricking.grid.pos(x, y)
                point(p,radius: radius,colour: fg)
            }
        }
        
        self.context.setLineWidth(self.dimensions[.Line]*self.dimensionScaling)
        pricking.lines.forEach { line in
            let l = invert(pricking.asScreenLine(line)) // invert(Line(grid: pricking.grid, line: line))
            syslog.debug("\(line) : \(l)")
            self.line(l)
        }
    }
}
