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
    @IBOutlet weak var drawingArea : LaceView!
    @IBOutlet weak var scaleField : NSTextField!
    //@IBOutlet weak var testPanel: PrintableView!
    
    
    @IBOutlet weak var window: NSWindow!
    
    
    var initialised : Bool = false
    
    var dataState = Trivalent<DataHandler>()
    
    var width: Int32 = 1
    var height: Int32 = 1
    var path : String?
    
    var pricking : Pricking {
        get { self.drawingArea.pricking }
        set { self.drawingArea.pricking = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawingArea.backgroundColor = .white
        //self.drawingArea.setDelegate(ViewDelegate())
        self.drawingArea.initialise()
        
        self.width = Defaults.get(forKey: "\(Self.prefix)width") ?? 1
        self.height = Defaults.get(forKey: "\(Self.prefix)height") ?? 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvent(_ :)), name: SettingsPanel.DefaultsUpdated, object: nil)
        
        self.updateZoom(self.zoomField)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        

        
        
        // if datasource has been set, switch straight to active mode;
        // otherwise wait mode : use an atomic (or an Actor) to synchronise this
        //
        // ifNoData { wait stuff, i.e. do nothing }
        // else {
       
        // }
        
        //self.backup?.startTimedBackups()
    }
    
    override func viewWillDisappear() {
        //AutoSaveProcessor.set(pricking: self.pricking)
    }
    
    
    
    @objc func updateEvent(_ n : Notification) {
        DispatchQueue.main.async {
            syslog.info("Reloading defaults")
            self.drawingArea.reload()
        }
    }
    
    @IBAction func updateZoom(_ s : NSSlider) {
        DispatchQueue.main.async { [self] in
            let sc=zoomField.doubleValue/1000.0
            self.drawingArea.setSpacing(inMetres: sc)
            self.scaleField.stringValue=String(format: "spacing = %.1f mm", sc*1000.0)
        }
    }
    
    func setSize(width: Int32,height: Int32) {
        self.height=height
        self.width=width
        syslog.debug("Changed to \(self.width) x \(self.height)")
        self.drawingArea.setSize(width: width, height: height)
        self.view.window?.title="Torchon \(self.width)x\(self.height)"
    }
    
    

    @IBAction func sizeDidChange(_ field: NSTextField?) {
        let w  = widthField.intValue
        let h = heightField.intValue
        
        if w != self.width || h != self.height {
            self.setSize(width: w, height: h)
        }
        
    }
    
    
    enum SaveActions {
        case Save
        case SaveAs
        case New
    }
    
    
    
    @IBAction func loadPreferences(_ sender: NSMenuItem) { let _ = SettingsPanel.launch() }
    
    func saveCurrent(_ action : SaveActions) {
        do {
            /*
            guard let p = drawingArea?.pricking else { throw PrickingError.CannotFindPricking }
            switch action {
            case .Save:
                if FilePaths.hasCurrent { try File(url: FilePaths.current).save(p) }
                else { saveCurrent(.SaveAs) }
            case .SaveAs:
                let url = try File().save(p)
                FilePaths.newFile(url)
            default:
                break
            }
             */
        }
        catch(let e) { syslog.error("Error \(e)")}
    }
    
    @IBAction func doSave(_ item : NSMenuItem?) {
        self.saveCurrent(.Save)
    }
    
    @IBAction func doSaveAs(_ item : NSMenuItem?) {
        self.saveCurrent(.SaveAs)
    }
    
    @IBAction func doExport(_ item: NSMenuItem?) {
        let _ = PrintingPanel.launch(pricking: self.drawingArea.pricking)
    }
    
    @IBAction func doPinSpacingHelper(_ item : NSMenuItem?) {
        let _ = ThreadCalculator.launch()
    }
    
    @IBAction func doThreadCatalogue(_ sender: NSMenuItem) {
        let _ = ThreadListPanelView.launch()
    }
    
    
    
    
    
    
}

