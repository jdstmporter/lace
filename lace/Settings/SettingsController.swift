//
//  SettingsController.swift
//  lace
//
//  Created by Julian Porter on 16/04/2022.
//

import Foundation
import AppKit

enum ViewPart : Int, CaseIterable {
    case Background = 0
    case Grid = 1
    case Pin = 2
    case Line = 3
}

typealias ViewPartSizes = [ViewPart:Double]

class DrawingView : NSView {
    
    
    var wells : [ViewPart:NSColorWell] = [:]
    var colours = ViewPartColours()
    
    var fields : [ViewPart:NSTextField] = [:]
    var values : [ViewPart:Double] = [:]
    
    @IBOutlet weak var backgroundColour: NSColorWell!
    @IBOutlet weak var gridColour: NSColorWell!
    @IBOutlet weak var pinColour: NSColorWell!
    @IBOutlet weak var lineColour: NSColorWell!
    @IBOutlet weak var gridSize: NSTextField!
    @IBOutlet weak var pinSize: NSTextField!
    @IBOutlet weak var lineSize: NSTextField!
    
    @IBOutlet weak var laceView : LaceView!
    
    func save() {
        colours.touch()
        Defaults().colours=colours
    }
    
    
    func touch() {
        ViewPart.allCases.forEach { row in
            if let well = wells[row] {
                let c = well.color.calibratedRGB
                colours[row] = c
            }
            if let field = fields[row] { values[row] = field.doubleValue }
        }
        
        DispatchQueue.main.async { [self] in
            laceView.colours = colours
        }
        
    }
    func loadColours(_ col : ViewPartColours) {
        col.touch()
        ViewPart.allCases.forEach { row in
            if col.has(row)  { wells[row]?.color = colours[row] }
            if let value = values[row] { fields[row]?.doubleValue = value }
        }
        
        DispatchQueue.main.async { [self] in
            laceView.colours = colours
        }
    }
    func reloadColours() { self.loadColours(self.colours) }
    
    func initialise() {
        wells[.Background] = backgroundColour
        wells[.Grid] = gridColour
        wells[.Pin] = pinColour
        wells[.Line] = lineColour
        
        fields[.Grid] = gridSize
        fields[.Pin] = pinSize
        fields[.Line] = lineSize
        
        self.loadColours(Defaults().colours)
        
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
            print("Changed in row \(matched)")
        }
        else { print("Matched somewhere funny") }
        self.touch()
        colours.forEach { print("\($0.key) : \($0.value)") }
    }
    
    func sizesEvent(_ field : NSTextField) {
        self.touch()
        values.forEach { print("\($0.key) : \($0.value)") }
        
    }
    
    func colour(_ row : ViewPart) -> NSColor? { colours[row] }

}


class SettingsPanel : NSPanel, LaunchableItem {
    
    static var lock = NSLock()
    static var nibname : NSNib.Name = NSNib.Name("Preferences")
    
    static var panel : SettingsPanel? = nil
    static var nib : NSNib?
    
    var firstTime : Bool = true
    @IBOutlet weak var drawingView: DrawingView!
    
 
    static func launch() -> SettingsPanel? {
        if panel==nil {
            panel=instance()
            panel?.initialise()
            
        }
        panel?.makeKeyAndOrderFront(nil)
    
        return panel
    }
    
    @discardableResult static func close() -> SettingsPanel? {
        panel?.performClose(nil)
        return panel
    }
    
    static func reset() {
        guard panel != nil else { return }
        close()
        panel=nil
    }
    
    func initialise() {
        if firstTime {
            drawingView.initialise()
            // do first time round things
            
            //NotificationCenter.default.addObserver(self, selector: #selector(colourChanged(_:)), name: //NSColorPanel.colorDidChangeNotification, object: nil)
            firstTime=false
        }

    }
    

    
    @IBAction func backgroundCallback(_ sender: NSColorWell) {
        sender.color = sender.color.calibratedRGB
        print("Background colour is now \(sender.color)")
        drawingView.colourEvent(sender)
    }
    
    @IBAction func textCallback(_ sender: NSTextField) {
        print("TEXT EVENT")
        drawingView.sizesEvent(sender)
    }
    
}
