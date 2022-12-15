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
    var fields : [ViewPart:NSTextField] = [:]
    //private var cols = ViewColours(.Temp)
    //private var dims = ViewDimensions(.Temp)
    
    @IBOutlet weak var backgroundColour: NSColorWell!
    @IBOutlet weak var gridColour: NSColorWell!
    @IBOutlet weak var pinColour: NSColorWell!
    @IBOutlet weak var lineColour: NSColorWell!
    @IBOutlet weak var gridSize: NSTextField!
    @IBOutlet weak var pinSize: NSTextField!
    @IBOutlet weak var lineSize: NSTextField!
    
    @IBOutlet weak var laceView : LaceView!
    
    
    var dims : ViewDimensions! {
        get { laceView?.dims }
        set { laceView?.dims = newValue }
    }
    var cols : ViewColours! {
        get { laceView?.colours }
        set { laceView?.colours = newValue }
    }
    
    
    func touch() {
        ViewPart.allCases.forEach { row in
            if let well = wells[row] { cols[row]=well.color }
            if let field = fields[row] { dims[row]=field.doubleValue }
        }
        
        laceView.touch()
        
    }
    
    func revert() {
        cols.revert()
        laceView?.dims.revert()
        ViewPart.allCases.forEach { row in
            wells[row]?.color = cols[row]
            fields[row]?.doubleValue = dims[row]
        }
        laceView.touch()
        
    }
    
    
    func load()  {
        self.laceView.reload()
        DispatchQueue.main.async { [self] in
            ViewPart.allCases.forEach { row in
                if let well = wells[row] { well.color = cols[row] }
                if let text = fields[row] { text.doubleValue = dims[row] }
            }
        }
        
    }
    
    func save() throws {
        cols.commit()
        dims.commit()
        self.touch()
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
        //laceView.MaxWidth = 10.0
        //laceView.MaxHeight = 10.0
        laceView.spacingInMetres = 0.005 // 5 mm
        laceView.pricking=Pricking(10,10)
        (0..<5).forEach { n in
            let p = GridPoint(2*n, 2*n)
            laceView.pricking.grid.flip(p)
        }
        laceView.pricking.lines.append(GridLine(GridPoint(0,0), GridPoint(8,8)))
        laceView.pricking.lines.append(GridLine(GridPoint(1,1), GridPoint(1,7)))
        
        DispatchQueue.main.async { [self] in
            //laceView.setDelegates(cols,dims)
            laceView.touch()
        }
    }
    
    func colourEvent(_ well : NSColorWell) {
        if let matched = ViewPart.init(rawValue: well.tag) {
            syslog.debug("Changed in row \(matched)")
        }
        else { syslog.debug("Matched somewhere funny") }
        self.touch()
        ViewPart.allCases.forEach { syslog.debug("\($0) : \(self.cols[$0])") }
    }
    
    func sizesEvent(_ field : NSTextField) {
        self.touch()
    }
    
    func colour(_ row : ViewPart) -> NSColor? { self.cols[row] }
    
    func cleanup() {
        NSColorPanel.shared.close()
    }

}

