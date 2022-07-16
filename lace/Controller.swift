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
    
    @IBOutlet weak var testPanel: PrintableView!
    
    
    var width : Int = 1
    var height : Int = 1
    var path : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawingArea.backgroundColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvent(_ :)), name: SettingsPanel.DefaultsUpdated, object: nil)
        
        
        if let w=self.view.window {
            let d=w.deviceDescription
            d.forEach { kv in
                let r=kv.value as? NSValue
                print("\(kv.key) = \(r)")
            }
        }
        
        else { syslog.say("No Window") }
        let id = CGMainDisplayID()
        let sz = CGDisplayScreenSize(id)
        let bd = CGDisplayBounds(id)
        print("Display \(id) has size \(sz) and bounds \(bd)")
    }
    
    @objc func updateEvent(_ n : Notification) {
        DispatchQueue.main.async {
            syslog.info("Reloading defaults")
            self.drawingArea.reload()
        }
    }
    

    @IBAction func sizeDidChange(_ field: NSTextField?) {
        let w : Int = numericCast(widthField.intValue)
        let h : Int = numericCast(heightField.intValue)
        
        if w != self.width || h != self.height {
            self.height=h
            self.width=w
            syslog.debug("Changed to \(self.width) x \(self.height)")
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
        catch(let e) { syslog.error("Error \(e)")}
    }
    
    @IBAction func doSave(_ item : NSMenuItem?) {
        self.saveCurrent(pick: false)
    }
    
    @IBAction func doSaveAs(_ item : NSMenuItem?) {
        self.saveCurrent(pick: true)
    }
    
    @IBAction func doExport(_ item: NSMenuItem?) {
        let _ = PrintingPanel.launch(pricking: self.drawingArea.pricking)
        
        /*
        syslog.info("Trying to export")
        let dpi = 300
        let spacing = 0.2
        let w = drawingArea.pricking.grid.width
        let h = drawingArea.pricking.grid.height
        
        do {
            guard let v = ImageCG(grid: drawingArea.pricking.grid, width: w, height: h, spacing: spacing,dpi: dpi) else { throw LaceError.CannotMakeImage }
            v.draw()
            try v.renderToLocation(url: URL(fileURLWithPath: "/Users/julianporter/fred.png"))
            syslog.info("Export may have succeeded")
        }
        catch(let e) { syslog.error("Error: \(e)") }
         */
    }
    
    @IBAction func doPinSpacingHelper(_ item : NSMenuItem?) {
        let _ = ThreadCalculator.launch()
    }
    
    @IBAction func doTest(_ item : NSMenuItem?) {
        if let rep = testPanel.render() {
            let cg=rep.cgImage!
            let renderer=RenderPNG(image: cg, dpi: NSSize(width: 300, height: 300))
            try? renderer.renderToLocation(path: URL(fileURLWithPath: "/Users/julianporter/fred.png"))
        }
        testPanel.load(pricking: drawingArea.pricking, spacingInM: 0.2, dpM: 120)
    }
    
    
    
    
}
