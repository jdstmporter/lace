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
    
    
    var info = ThreadInfo()
    var selectedMaterial : String = ""
    var matchingThreads : Threads.ThreadGroup = []
    var matchedThreads : Threads.ThreadGroup = []
    var pinSeparation : Decimal?
    
    static let defaultResolutions : [Int] = [72,150,300,600,720,1200,2400]
    var calc : ThreadCalc?
    
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
    
    
    
    
    
    @IBAction func resolutionsButton(_ sender: NSPopUpButton) {
    }
    
    
    @IBAction func choiceAction(_ button: NSButton!) {
        if printerButton.state == .on {
            printers.isEnabled = true
            printerAction(nil)
        }
        else {
            printers.isEnabled = false
            resolutions.removeAllItems()
            resolutions.addItems(withTitles: PrintingPanel.defaultResolutions.map { "\($0)" } )
            resolutions.selectItem(at: 0)
        }
    }
    
    @IBAction func printerAction(_ button: NSPopUpButton!) {
        guard let pr = printSystem?[printers.indexOfSelectedItem] else { return }
        let res = pr.resolutions.map { $0.width.description }
        resolutions.removeAllItems()
        resolutions.addItems(withTitles: res)
        resolutions.selectItem(at: 0)
    }
    
    static func launch() -> PrintingPanel? {
        if panel==nil {
            panel=instance()
            panel?.initialise()
            
        }
        panel?.makeKeyAndOrderFront(nil)
    
        return panel
    }
    
    @discardableResult static func close() -> PrintingPanel? {
        panel?.performClose(nil)
        return panel
    }
    
    func initialise() {
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

    }
}

