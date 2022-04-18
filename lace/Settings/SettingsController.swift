//
//  SettingsController.swift
//  lace
//
//  Created by Julian Porter on 16/04/2022.
//

import Foundation
import AppKit



class DrawingView : NSView {
    
    enum Row : Int, CaseIterable {
        case Background = 0
        case Grid = 1
        case Pin = 2
        case Line = 3
    }
    var wells : [Row:NSColorWell] = [:]
    var colours : [Row:NSColor] = [:]
    
    var fields : [Row:NSTextField] = [:]
    var values : [Row:Double] = [:]
    
    @IBOutlet weak var backgroundColour: NSColorWell!
    @IBOutlet weak var gridColour: NSColorWell!
    @IBOutlet weak var pinColour: NSColorWell!
    @IBOutlet weak var lineColour: NSColorWell!
    @IBOutlet weak var gridSize: NSTextField!
    @IBOutlet weak var pinSize: NSTextField!
    @IBOutlet weak var lineSize: NSTextField!
    
    @IBOutlet weak var laceView : LaceView!
    
    func saveColours() {
        Row.allCases.forEach { row in
            if let well = wells[row] { colours[row] = well.color }
            if let field = fields[row] { values[row] = field.doubleValue }
        }
        
        DispatchQueue.main.async { [self] in
            laceView.pinColour = colours[.Pin] ?? .black
            laceView.gridColour = colours[.Grid] ?? .black
            laceView.lineColour = colours[.Line] ?? .black
            laceView.backgroundColor = colours[.Background] ?? .white
            laceView.touch()
        }
        
    }
    func loadColours() {
        Row.allCases.forEach { row in
            if let colour = colours[row] { wells[row]?.color = colour }
            if let value = values[row] { fields[row]?.doubleValue = value }
        }
    }
    
    func initialise() {
        wells[.Background] = backgroundColour
        wells[.Grid] = gridColour
        wells[.Pin] = pinColour
        wells[.Line] = lineColour
        
        fields[.Grid] = gridSize
        fields[.Pin] = pinSize
        fields[.Line] = lineSize
        
        laceView.MaxWidth = 10.0
        laceView.MaxHeight = 10.0
        laceView.touch()
    }
    
    func colourEvent(_ well : NSColorWell) {
        if let matched = Row.init(rawValue: well.tag) {
            print("Changed in row \(matched)")
        }
        else { print("Matched somewhere funny") }
        self.saveColours()
        colours.forEach { print("\($0.key) : \($0.value)") }
    }
    
    func sizesEvent(_ field : NSTextField) {
        self.saveColours()
        values.forEach { print("\($0.key) : \($0.value)") }
        
    }
    
    func colour(_ row : Row) -> NSColor? { colours[row] }

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
        print("Background colour is now \(sender.color)")
        drawingView.colourEvent(sender)
    }
    
    @IBAction func textCallback(_ sender: NSTextField) {
        print("TEXT EVENT")
        drawingView.sizesEvent(sender)
    }
    
}
