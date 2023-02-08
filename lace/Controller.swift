//
//  Controller.swift
//  lace
//
//  Created by Julian Porter on 01/04/2022.
//

import Foundation
import Cocoa



class PopoverWindow : NSWindow, LaunchableItem {
    
    static var nibname: NSNib.Name = NSNib.Name("startup")
    static var lock: NSLock = NSLock()
    
    enum Choice {
        case Continue
        case Load(url: URL?)
        case New(width: Int,height: Int)
        
        var str : String {
            switch self {
            case .Continue:
                return "Continue"
            case .Load(let url):
                return "Load \(url?.relativePath ?? "-")"
            case .New(let width,let height):
                return "New \(width) x \(height)"
            }
        }
        
        var path : URL? {
            switch self {
            case .Load(let url):
                return url
            default:
                return  nil
            }
        }
        var size : GridSize? {
            switch self {
            case .New(let width,let height):
                return GridSize(width,height)
            default:
                return  nil
            }
        }
    }
    
    
    var outcome : PopoverWindow.Choice?
    
    @IBOutlet weak var blanker: NSButton!
    @IBOutlet weak var continuer: NSButton!
    @IBOutlet weak var loader: NSButton!
    @IBOutlet weak var pather: NSPathControl!
    @IBOutlet weak var heighter: NSTextField!
    @IBOutlet weak var width: NSTextField!
    
    func initialise() {
        let c = FilePaths.hasCurrent
        continuer.isEnabled = c
        if c {
            continuer.state = .on
            pather.url = FilePaths.current
        }
        else {
            blanker.state = .on
            pather.isHidden = true
        }
        
    }
    static var popover : PopoverWindow? = nil
    static func launch() -> PopoverWindow? {
        if popover==nil {
            popover=instance()
            popover?.initialise()
        }
        return popover
    }
    
    
    var wid : Int { width.integerValue }
    var hei : Int { heighter.integerValue }
    
    @IBAction func radioButtons(_ sender: NSButton) {
        [self.blanker,self.loader,self.continuer].forEach { $0.state = ($0==sender) ? .on : .off }
    }
    

    @IBAction func buttonAction(_ sender: NSButton) {
        var outcome : PopoverWindow.Choice? = nil
        if continuer.state == .on { outcome = .Continue }
        else if loader.state == .on { outcome = .Load(url: pather.url) }
        else  if blanker.state == .on { outcome = .New(width: wid, height: hei) }
        
        self.outcome=outcome
        self.sheetParent?.endSheet(self, returnCode: .OK)
        
    }
    
    typealias Handler = (NSApplication.ModalResponse) -> Void
    typealias Callback = (PopoverWindow.Choice?) -> Void
    func handler(_ callback : @escaping Callback) -> Handler {
        { _ in callback(self.outcome) }
    }
    
    func start(_ w: NSWindow,callback: @escaping Callback) {
        w.beginSheet(self,completionHandler: self.handler(callback))
    }
}




class Controller : NSViewController {
    static let prefix = "GridSize-"
    
    @IBOutlet weak var zoomField: NSSlider!
    @IBOutlet weak var widthField : NSTextField!
    @IBOutlet weak var heightField : NSTextField!
    @IBOutlet weak var drawingArea : LaceView!
    @IBOutlet weak var scaleField : NSTextField!
    //@IBOutlet weak var testPanel: PrintableView!
    
    
    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var popoverWindow: PopoverWindow!
    var callback : PopoverWindow.Callback?
    var initialised : Bool = false
    
    var width : Int = 1
    var height : Int = 1
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
        if let p = AutoSaveProcessor.load() {
            self.pricking=p
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        guard !self.initialised, let pop=PopoverWindow.launch() else { return }
        pop.start(self.window, callback: { c in self.callback(c ?? .Continue) })
        
        //self.backup?.startTimedBackups()
    }
    
    override func viewWillDisappear() {
        AutoSaveProcessor.save(self.pricking)
    }
    
    func callback(_ c : PopoverWindow.Choice) {
        syslog.info("Choice is \(c)")
        switch c {
        case .Continue:
            if let p = AutoSaveProcessor.load() {
                self.pricking=p
            }
        case .Load(url: let u):
            print(u?.description ?? "")
            break
        case .New(width: let w, height: let h):
            AutoSaveProcessor.new()
            self.setSize(width: w, height: h)
        
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

