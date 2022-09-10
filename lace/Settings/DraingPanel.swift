//
//  DraingPanel.swift
//  lace
//
//  Created by Julian Porter on 24/04/2022.
//

import Foundation
import AppKit

class DrawingView : NSView, SettingsFacet {
    
    
    var wells : [ViewPart:NSColorWell] = [:]
    var colours = ViewColours(mode : .Temporary)
    
    var fields : [ViewPart:NSTextField] = [:]
    //var values = ViewPartDimensions()
    var values = ViewDimensions(mode: .Temporary)
    
    @IBOutlet weak var backgroundColour: NSColorWell!
    @IBOutlet weak var gridColour: NSColorWell!
    @IBOutlet weak var pinColour: NSColorWell!
    @IBOutlet weak var lineColour: NSColorWell!
    @IBOutlet weak var gridSize: NSTextField!
    @IBOutlet weak var pinSize: NSTextField!
    @IBOutlet weak var lineSize: NSTextField!
    
    @IBOutlet weak var laceView : LaceView!
    
    
    
    
    func touch() {
        ViewPart.allCases.forEach { row in
            if let well = wells[row] { colours[row] = well.color }
            if let field = fields[row] { values[row] = field.doubleValue }
        }
        
        DispatchQueue.main.async { [self] in
            laceView.colours = colours
            laceView.dimensions = values
        }
        
    }
    
    func resetColours() {
        ViewPart.allCases.forEach { row in
            if colours.has(row)  { wells[row]?.color = colours[row] }
            //if values.has(row) { fields[row]?.doubleValue = values[row] }
        }
        values.revert()
    }
    
    
    func load()  {
        //self.laceView.dimensions=ViewPartsDimensionsTransient.defaults()
        self.laceView.dimensions=self.values
        colours.commit()
        DispatchQueue.main.async { [self] in
            ViewPart.allCases.forEach { row in
                if let well=wells[row] { well.color=colours[row] }
                if let text = fields[row] { text.doubleValue = values[row] }
            }
        }
        
    }
    
    func save() throws {
        ViewPart.allCases.forEach { row in
            if let well=wells[row]  { colours[row]=well.color }
            //if let field=fields[row] { values[row]=field.doubleValue }
        }
        
        //self.values.touch()
        self.colours.commit()
        self.values.commit()
    }
    
    func initialise() {
        wells[.Background] = backgroundColour
        wells[.Grid] = gridColour
        wells[.Pin] = pinColour
        wells[.Line] = lineColour
        
        fields[.Grid] = gridSize
        fields[.Pin] = pinSize
        fields[.Line] = lineSize
        
        self.load()
        
        
        // set up dummy pricking
        laceView.MaxWidth = 10.0
        laceView.MaxHeight = 10.0
        laceView.pricking=Pricking(10,10)
        (0..<5).forEach { n in
            let p = GridPoint(2*n, 2*n)
            laceView.pricking.grid.flip(p)
        }
        laceView.pricking.lines.append(GridLine(GridPoint(0,0), GridPoint(8,8)))
        laceView.pricking.lines.append(GridLine(GridPoint(1,1), GridPoint(1,7)))
        
        laceView.touch()
    }
    
    func colourEvent(_ well : NSColorWell) {
        if let matched = ViewPart.init(rawValue: well.tag) {
            syslog.debug("Changed in row \(matched)")
        }
        else { syslog.debug("Matched somewhere funny") }
        self.touch()
        ViewPart.allCases.forEach { syslog.debug("\($0) : \(self.colours[$0])") }
    }
    
    func sizesEvent(_ field : NSTextField) {
        self.touch()
        //values.forEach { syslog.debug("\($0.key) : \($0.value)") }
        
    }
    
    func colour(_ row : ViewPart) -> NSColor? { colours[row] }
    
    func cleanup() {
        NSColorPanel.shared.close()
    }

}

