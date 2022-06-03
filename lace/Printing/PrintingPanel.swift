//
//  PrintingPanel.swift
//  lace
//
//  Created by Julian Porter on 22/05/2022.
//

import AppKit



class PrintingPanel : NSPanel, LaunchableItem, ThreadCalcDelegate {
    
    //var defaults = PrintDefaults()
    
    var laceKindName: String {
        get {laceKindList.titleOfSelectedItem ?? "" }
        set { laceKindList.selectItem(withTitle: newValue) }
    }
    var laceKind : LaceKind {
        get { LaceKind(laceKindList.titleOfSelectedItem) }
        set { laceKindList.selectItem(withTitle: newValue.name) }
    }
    var threadName: String {
        get { threadKind.titleOfSelectedItem ?? "" }
        set { threadKind.selectItem(withTitle: newValue) }
    }
    var threadIndex: Int { threadKind.indexOfSelectedItem }
    var material : String {
        get { materialKind.titleOfSelectedItem ?? "" }
        set { materialKind.selectItem(withTitle: newValue) }
    }
    var searchString: String { search.stringValue }
    var pinSpacing : String {
        get { pinSpace.stringValue }
        set { pinSpace.stringValue=newValue }
    }
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
    var printerOrList : Bool {
        get { printers.isEnabled }
        set {
            printerButton.state = newValue ? .on : .off
            choiceAction(nil)
        }
    }
    var resolution : Int {
        get { printerResolutionDPI }
        set {
            resolutions.selectItem(withTitle: newValue.description)
            resolutionsButton(nil)
        }
    }
    var printer : String {
        get { printers.titleOfSelectedItem ?? "" }
        set {
            printers.selectItem(withTitle: newValue)
            printerAction(nil)
        }
    }
    var threadMode : ThreadMode {
        get { threadFromLibrary.state == .on ? .Library : .Custom }
        set {
            let state : NSButton.StateValue = (newValue == .Library) ? .on : .off
            threadFromLibrary.state = state
            threadChoice(nil)
        }
    }
    var spaceMode : SpaceMode {
        get {
            (laceKindButton.state == .on) ? .Kind :
            (customWindings.state == .on) ? .CustomKind : .CustomSpace
        }
        set {
            switch newValue {
            case .Kind:
                laceKindButton.state = .on
            case .CustomKind:
                customWindings.state = .on
            case .CustomSpace:
                customMeasurement.state = .on
            }
            laceKindChoice(nil)
        }
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
    var printerresolutionDPISize : NSSize { NSSize(side: printerResolutionDPI) }
    
    static let InchesPerMetre : Float = 39.3701
    static let defaultResolutions : [Int] = [72,150,300,600,720,1200,2400]
    var calc : ThreadCalc = ThreadCalc()
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
        self.calc.threadAction(.Material)
    }
    @IBAction func searchAction(_ sender: Any!) {
        self.calc.threadAction(.Search)
    }
    @IBAction func threadAction(_ sender: Any!) {
        self.calc.threadAction(.Thread)
    }
    @IBAction func laceKindAction(_ sender: Any!) {
        self.calc.threadAction(.Lace)
    }
    @IBAction func pinSpaceCustomAction(_ sender: Any!) {
        self.calc.threadAction(.Space)
    }
  
    @IBAction func threadChoice(_ sender: Any!) {
        let mode = threadMode
        switch mode {
        case .Library:
            materialKind.isEnabled=true
            threadKind.isEnabled=true
            threadWind.isEditable=false
        case .Custom:
            materialKind.isEnabled=false
            threadKind.isEnabled=false
            threadWind.isEditable=true
        }
        self.calc.setMode(thread: mode)
    }
 
    @IBAction func laceKindChoice(_ sender: Any!) {
        let mode=spaceMode
        switch mode {
        case .Kind:
            laceKindList.isEnabled=true
            kindWind.isEditable=false
            pinSpace.isEditable=false
        case .CustomKind:
            laceKindList.isEnabled=false
            kindWind.isEditable=true
            pinSpace.isEditable=false
        case .CustomSpace:
            laceKindList.isEnabled=false
            kindWind.isEditable=false
            pinSpace.isEditable=true
        }
        self.calc.setMode(space: mode)
    }
 
    @IBAction func closeAction(_ sender: Any) {
        PrintingPanel.close()
    }
    
    private func makeImage() -> RenderPNG? {
        guard let pricking = self.pricking else { return nil }
        let view = PrintableView(frame: NSRect())
        let sp = self.calc.pinSeparation.doubleValue/1000.0
        view.load(pricking: pricking, spacingInM: sp, dpM: printerResolutionDPM)
        guard let cg = view.render()?.cgImage else { return nil }
        return RenderPNG(image: cg, dpi: printerresolutionDPISize)
    }
    
    
    @IBAction func imageToFile(_ sender: Any) {
        guard let renderer = makeImage() else { return }
        let fd = FilePicker(def : "../pricking.png",types : ["png"])
        if fd.runSync() {
            try? renderer.renderToLocation(path: fd.url)
        }
    }
    
    @IBAction func imageToPrinter(_ sender: Any) {
        guard let renderer = makeImage() else { return }
        guard let data = try? renderer.renderToData() else { return }
        loadAndPrint(data: data)
    }
 
    @IBAction func resolutionsButton(_ sender: NSPopUpButton!) {
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
            
            calc=ThreadCalc()
            calc.delegate=self
            
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
            self.calc.threadAction()
         
            // do first time round things
            
            //NotificationCenter.default.addObserver(self, selector: #selector(colourChanged(_:)), name: //NSColorPanel.colorDidChangeNotification, object: nil)
            firstTime=false
        }
        self.pricking=pricking

    }
}

