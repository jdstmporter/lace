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
    
    var popover : PopoverWindow!
    @IBOutlet weak var popoverWindow: PopoverWindow!
    var callback : PopoverWindow.Callback?
    var initialised : Bool = false
    
    var dataState = Trivalent<DataHandler>()
    
    var width : Int = 1
    var height : Int = 1
    var path : String?
    
    var pricking : Pricking {
        get { self.drawingArea.pricking }
        set { self.drawingArea.pricking = newValue }
    }
    
    func setDataSource(handler: DataHandler?) {
        Task {
            let state = await self.dataState.set(handler)
            await self.setViewMode(state: state)
        }
    }
    

    func setViewMode(state : DataState) async {
        
        await MainActor.run {
            guard !self.initialised, let pop=self.popover else { return }
            switch state {
            case .Good:
                pop.set(mode: .Success)
                self.initialised=true
            case .Bad:
                pop.set(mode: .Failure)
                self.initialised=true
            case .Unset:
                pop.set(mode: .Loading)
                break
            }
        }
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
        if let p = AutoSaveProcessor.load() {
            self.pricking=p
        }
        
        
        if let pop = PopoverWindow.launch() {
            self.popover=pop
            self.popover.start(self.window, callback: { c in self.callback(c ?? .Continue) })
            self.popover.set(mode: .Loading)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        

        Task {
            let state = await dataState.state
            await self.setViewMode(state: state)
        }
        
        // if datasource has been set, switch straight to active mode;
        // otherwise wait mode : use an atomic (or an Actor) to synchronise this
        //
        // ifNoData { wait stuff, i.e. do nothing }
        // else {
        guard !self.initialised, let pop=PopoverWindow.launch() else { return }
        pop.start(self.window, callback: { c in self.callback(c ?? .Continue) })
        // }
        
        //self.backup?.startTimedBackups()
    }
    
    override func viewWillDisappear() {
        AutoSaveProcessor.set(pricking: self.pricking)
    }
    
    func callback(_ c : PopoverWindow.Choice) {
        syslog.info("Choice is \(c)")
        switch c {
        case .Continue:
            if let p = AutoSaveProcessor.load() {
                self.pricking=p
            }
            break
        case .Load(url: let u):
            print(u?.description ?? "")
            break
        case .New(width: let w, height: let h):
            self.setSize(width: w, height: h)
            AutoSaveProcessor.set(pricking: self.pricking, immediate: true)
            break
        case .Accept:
            break
        }
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
    
    func setSize(width: Int,height: Int) {
        self.height=height
        self.width=width
        syslog.debug("Changed to \(self.width) x \(self.height)")
        self.drawingArea.setSize(width: width, height: height)
        self.view.window?.title="Torchon \(self.width)x\(self.height)"
    }
    
    

    @IBAction func sizeDidChange(_ field: NSTextField?) {
        let w : Int = numericCast(widthField.intValue)
        let h : Int = numericCast(heightField.intValue)
        
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

