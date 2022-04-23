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
    var values = ViewPartDimensions()
    
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
        
        DispatchQueue.main.async { [self] in laceView.colours = colours }
        
    }
    
    func resetColours() {
        ViewPart.allCases.forEach { row in
            if colours.has(row)  { wells[row]?.color = colours[row] }
            if values.has(row) { fields[row]?.doubleValue = values[row] }
        }
    }
    
    
    func load()  {
        colours.loadDefault()
        self.colours.touch()
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
            if let field=fields[row] { values[row]=field.doubleValue }
        }
        self.colours.touch()
        try colours.saveDefault()
        try values.saveDefault()
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
    static let DefaultsUpdated = Notification.Name("$_LACE_DEFAULTS_UPDATED_EVENT")
    
    
    static var lock = NSLock()
    static var nibname : NSNib.Name = NSNib.Name("Preferences")
    
    static var panel : SettingsPanel? = nil
    static var nib : NSNib?
    
    @IBOutlet weak var tabs: NSTabView!
    @IBOutlet weak var cancel: NSButton!
    @IBOutlet weak var apply: NSButton!
    
    var firstTime : Bool = true
    @IBOutlet weak var drawingView: DrawingView!
    
    @IBAction func toolbarAction(_ item: NSToolbarItem) {
        let idx = item.tag
        guard idx>=0, idx<5 else { return }
        tabs?.selectTabViewItem(at: idx)
    }
    
    
    @IBAction func cancelButtonAction(_ button: NSButton) {
        SettingsPanel.close()
    }
    
   
    
    @IBAction func applyButtonAction(_ button: NSButton) {
        do {
            guard let d = self.drawingView else { return }
            try d.save()
            NotificationCenter.default.post(name: SettingsPanel.DefaultsUpdated, object: nil)
        }
        catch(let e) { print("Error: \(e) while saving defaults") }
    }
    
 
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
