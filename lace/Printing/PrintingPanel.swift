//
//  PrintingPanel.swift
//  lace
//
//  Created by Julian Porter on 22/05/2022.
//

import AppKit


class PrintingPanel : NSPanel, LaunchableItem, ThreadCalcDelegate {
    
    var laceKindName: String { laceKindList.titleOfSelectedItem ?? "" }
    var threadName: String { threadKind.titleOfSelectedItem ?? "" }
    var threadIndex: Int { threadKind.indexOfSelectedItem }
    var material : String { materialKind.titleOfSelectedItem ?? "" }
    var searchString: String { search.stringValue }
    var pinSpacing : String { get { pinSpace.stringValue } set { pinSpace.stringValue=newValue }}
    var pinSpacingFloat: Float { pinSpace.floatValue }
    
    func reset() {}
    
    var threadWinding: Int {
        get { threadWind.integerValue }
        set { threadWind.integerValue=newValue}
    }
    var laceKindWinding: Int {
        get { kindWind.integerValue }
        set { kindWind.integerValue=newValue }
    }
    func setThreads(items: [String]) {
        threadKind.removeAllItems()
        threadKind.addItems(withTitles: items)
        threadKind.selectItem(at: 0)
    }
    
    
    
    @IBOutlet weak var search: NSSearchField!
    @IBOutlet weak var materialKind: NSPopUpButton!
    @IBOutlet weak var threadKind: NSPopUpButton!
    @IBOutlet weak var threadWind: NSTextField!
    @IBOutlet weak var kindWind: NSTextField!
    @IBOutlet weak var pinSpace: NSTextField!
    static var lock = NSLock()
    static var nibname : NSNib.Name = NSNib.Name("Printing")
    static var panel : PrintingPanel? = nil
    var firstTime : Bool = true
    var printSystem : PrintSystem?
    var displayedResolutions : [Int] = []
    
    
    var info = ThreadInfo()
    var selectedMaterial : String = ""
    var matchingThreads : Threads.ThreadGroup = []
    var matchedThreads : Threads.ThreadGroup = []
    var pinSeparation : Decimal = 0
    var printerResolutionDPI : Int = 0
    var printerResolutionDPM : Int { Int(printerResolutionDPI.f32 * PrintingPanel.InchesPerMetre) }
    
    static let InchesPerMetre : Float = 39.3701
    static let defaultResolutions : [Int] = [72,150,300,600,720,1200,2400]
    var calc : ThreadCalc?
    var pricking: Pricking?
    
    @IBOutlet weak var view : NSView!
    @IBOutlet weak var printers : NSPopUpButton!
    @IBOutlet weak var printerButton : NSButton!
    @IBOutlet weak var listButton: NSButton!
    @IBOutlet weak var resolutions: NSPopUpButton!
    
    @IBOutlet weak var threadFromLibrary: NSButton!
    @IBOutlet weak var customThread: NSButton!
    @IBOutlet weak var laceKindButton: NSButton!
    @IBOutlet weak var customWindings: NSButton!
    @IBOutlet weak var customMeasurement: NSButton!
    @IBOutlet weak var laceKindList: NSPopUpButton!
    
    @IBOutlet weak var threadList: NSPopUpButtonCell!
    
    @IBAction func materialKindEvent(_ sender: Any!) {
        self.calc?.threadAction(.Material)
    }
    @IBAction func searchAction(_ sender: Any!) {
        self.calc?.threadAction(.Search)
    }
    @IBAction func threadAction(_ sender: Any!) {
        self.calc?.threadAction(.Thread)
    }
    @IBAction func laceKindAction(_ sender: Any!) {
        self.calc?.threadAction(.Lace)
    }
    @IBAction func pinSpaceCustomAction(_ sender: Any!) {
        self.calc?.threadAction(.Space)
    }
    @IBAction func threadChoice(_ sender: Any!) {
        if threadFromLibrary.state == .on {
            materialKind.isEnabled=true
            threadKind.isEnabled=true
            threadWind.isEditable=false
            self.calc?.setMode(thread: .Library)

        }
        else {
            materialKind.isEnabled=false
            threadKind.isEnabled=false
            threadWind.isEditable=true
            self.calc?.setMode(thread: .Custom)

        }
    }
    @IBAction func laceKindChoice(_ sender: Any!) {
        if laceKindButton.state == .on {
            laceKindList.isEnabled=true
            kindWind.isEditable=false
            pinSpace.isEditable=false
            self.calc?.setMode(space: .Kind)

        }
        else if customWindings.state == .on {
            laceKindList.isEnabled=false
            kindWind.isEditable=true
            pinSpace.isEditable=false
            self.calc?.setMode(space: .CustomKind)

        }
        else if customMeasurement.state == .on {
            laceKindList.isEnabled=false
            kindWind.isEditable=false
            pinSpace.isEditable=true
            self.calc?.setMode(space: .CustomSpace)
        }
    }
    
    
    
    
    @IBAction func closeAction(_ sender: Any) {
        PrintingPanel.close()
    }
    
    private func makeImage(pricking: Pricking) -> NSBitmapImageRep? {
        let view = PrintableView(frame: NSRect())
        let sp = (self.calc?.pinSeparation ?? 0) as NSDecimalNumber
        view.load(pricking: pricking, spacing: sp.doubleValue, dpi: printerResolutionDPI)
        return view.render()
    }
    
    
    @IBAction func imageToFile(_ sender: Any) {
        guard let pricking = self.pricking else { return }
        guard let image = makeImage(pricking: pricking)?.cgImage else { return }
        let renderer = RenderPNG(image: image, dpi: NSSize(side: self.printerResolutionDPI))
        
        let fd = FilePicker(def : "../pricking.png",types : ["png"])
        if fd.runSync() {
            try? renderer.renderToLocation(path: fd.url)
        }
        
    }
    
    @IBAction func imageToPrinter(_ sender: Any) {
        guard let pricking = self.pricking else { return }
        guard let image = makeImage(pricking: pricking)?.cgImage else { return }
        let renderer = RenderPNG(image: image, dpi: NSSize(side: self.printerResolutionDPI))
        guard let data = try? renderer.renderToData() else { return }
        loadAndPrint(data: data)
    }
    
    
    
    @IBAction func resolutionsButton(_ sender: NSPopUpButton) {
        let idx=resolutions.indexOfSelectedItem
        guard idx>=0, idx<displayedResolutions.count else { return }
        printerResolutionDPI = displayedResolutions[idx]
    }
    
    
    @IBAction func choiceAction(_ button: NSButton!) {
        if printerButton.state == .on {
            printers.isEnabled = true
            printerAction(nil)
        }
        else {
            printers.isEnabled = false
            displayedResolutions=PrintingPanel.defaultResolutions.copy
            resolutions.removeAllItems()
            resolutions.addItems(withTitles: displayedResolutions.asStrings )
            resolutions.selectItem(at: 0)
        }
    }
    
    @IBAction func printerAction(_ button: NSPopUpButton!) {
        guard let pr = printSystem?[printers.indexOfSelectedItem] else { return }
        displayedResolutions = pr.resolutions.map { $0.widthI }
        resolutions.removeAllItems()
        resolutions.addItems(withTitles: displayedResolutions.asStrings)
        resolutions.selectItem(at: 0)
    }
    
    static func launch(pricking: Pricking) -> PrintingPanel? {
        if panel==nil {
            panel=instance()
            panel?.initialise(pricking: pricking)
            
        }
        panel?.makeKeyAndOrderFront(nil)
    
        return panel
    }
    
    @discardableResult static func close() -> PrintingPanel? {
        panel?.performClose(nil)
        return panel
    }
    
    func initialise(pricking: Pricking?) {
        if firstTime {
            printSystem = try? PrintSystem()
            printers.removeAllItems()
            printSystem?.forEach { printers.addItem(withTitle: $0.name) }
            let sel = printSystem?.defaultPrinterIndex ?? 0
            printers.selectItem(at: sel)
            choiceAction(nil)
            
            calc=ThreadCalc(self)
            
            threadFromLibrary.state = .on
            let mk = Threads.groups()
            materialKind.removeAllItems()
            materialKind.addItems(withTitles: mk)
            
            
            laceKindButton.state = .on
            let items = LaceKind.allCases.map { $0.name }
            laceKindList.removeAllItems()
            laceKindList.addItems(withTitles: items)
            threadChoice(nil)
            laceKindChoice(nil)
            self.calc?.threadAction()
            
            
            
            
            
            
            // do first time round things
            
            //NotificationCenter.default.addObserver(self, selector: #selector(colourChanged(_:)), name: //NSColorPanel.colorDidChangeNotification, object: nil)
            firstTime=false
        }
        self.pricking=pricking

    }
}

