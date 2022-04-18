//
//  Controller.swift
//  lace
//
//  Created by Julian Porter on 01/04/2022.
//

import Foundation
import Cocoa

class Controller : NSViewController {
    
    @IBOutlet weak var widthField : NSTextField!
    @IBOutlet weak var heightField : NSTextField!
    @IBOutlet weak var drawingArea : LaceView!
    
    
    
    var width : Int = 1
    var height : Int = 1
    var path : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawingArea.backgroundColor = .white
    }
    

    @IBAction func sizeDidChange(_ field: NSTextField?) {
        let w : Int = numericCast(widthField.intValue)
        let h : Int = numericCast(heightField.intValue)
        
        if w != self.width || h != self.height {
            self.height=h
            self.width=w
            print("Changed to \(self.width) x \(self.height)")
            self.drawingArea.setSize(width: w, height: h)
        }
        
    }
    @IBAction func loadPreferences(_ sender: NSMenuItem) {
        let _ = SettingsPanel.launch()
    }
    
    func saveCurrent(pick : Bool) {
        do {
            guard let p = drawingArea?.pricking else { throw PrickingError.CannotFindPricking }
            try LoadSaveFiles().save(p, pick : pick)
        }
        catch(let e) { print("Error \(e)")}
    }
    
    @IBAction func doSave(_ item : NSMenuItem?) {
        self.saveCurrent(pick: false)
    }
    
    @IBAction func doSaveAs(_ item : NSMenuItem?) {
        self.saveCurrent(pick: true)
    }
    
    @IBAction func doExport(_ item: NSMenuItem?) {
        print("Trying to export")
        let sc = Double(72)*5.0
        let w = Double(drawingArea.pricking.grid.width+2)*sc
        let h = Double(drawingArea.pricking.grid.height+2)*sc
        
        do {
            guard let v = Image(grid: drawingArea.pricking.grid, width: Int(w), height: Int(h)) else { throw LaceError.CannotMakeImage }
            v.draw()
            try v.save()
            print("Export may have succeeded")
        }
        catch(let e) { print("Error: \(e)") }
    }
    
    
    
    
}
