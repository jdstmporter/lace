//
//  Controller.swift
//  lace
//
//  Created by Julian Porter on 01/04/2022.
//

import Foundation
import Cocoa

class Controller : NSViewController {
    static let prefix = "GridSize-"
    
    @IBOutlet weak var zoomField: NSSlider!
    @IBOutlet weak var widthField : NSTextField!
    @IBOutlet weak var heightField : NSTextField!
    @IBOutlet weak var styleMenu: NSPopUpButton!
    @IBOutlet weak var drawingArea : LaceView!
    
    //@IBOutlet weak var testPanel: PrintableView!
    
    
    var width : Int = 1
    var height : Int = 1
    var path : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawingArea.backgroundColor = .white
        self.drawingArea.setDelegate(ViewDelegate())
        self.drawingArea.initialise()
        
        self.width = Defaults.get(forKey: "\(Self.prefix)width") ?? 1
        self.height = Defaults.get(forKey: "\(Self.prefix)height") ?? 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvent(_ :)), name: SettingsPanel.DefaultsUpdated, object: nil)
        
        let items = LaceKind.allCases.map { $0.name }
        styleMenu.removeAllItems()
        styleMenu.addItems(withTitles: items)
        
        styleMenu.selectItem(at: LaceKind.Torchon.index)
    }
    
    @objc func updateEvent(_ n : Notification) {
        DispatchQueue.main.async {
            syslog.info("Reloading defaults")
            self.drawingArea.reload()
        }
    }
    
    @IBAction func updateZoom(_ s : NSSlider) {
        DispatchQueue.main.async { [self] in
            self.drawingArea.setSpacing(inMetres: zoomField.doubleValue/1000.0)
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
            self.view.window?.title="Torchon \(self.width)x\(self.height)"
        }
        
    }
    
    
    
    @IBAction func styleDidChange(_ field: NSPopUpButton?) {}
    
    
    @IBAction func loadPreferences(_ sender: NSMenuItem) { let _ = SettingsPanel.launch() }
    
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
    }
    
    @IBAction func doPinSpacingHelper(_ item : NSMenuItem?) {
        let _ = ThreadCalculator.launch()
    }
    
//    @IBAction func doTest(_ item : NSMenuItem?) {
//        if let rep = testPanel.render() {
//            let cg=rep.cgImage!
//            let renderer=RenderPNG(image: cg, dpi: NSSize(width: 300, height: 300))
//            try? renderer.renderToLocation(path: URL(fileURLWithPath: "/Users/julianporter/fred.png"))
//        }
//        testPanel.load(pricking: drawingArea.pricking, spacingInM: 0.2, dpM: 120)
//    }
    
    
    
    
}
