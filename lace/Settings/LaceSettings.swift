//
//  LaceSettings.swift
//  lace
//
//  Created by Julian Porter on 27/12/2022.
//

import AppKit

struct LaceState : Codable {
    var printer : Int // printer index >= 0 (set to default if OOR)
    var printerOrList : Bool // TRUE for printer, FALSE for list
    var resolution : Int // from drop-down; fit around if needs be
    
    var threadMode : ThreadMode // interconvertible with member of ThreadMode enum
    var material : Int // index in drop-down
    var thread : Int // index in drop-down
    var threading : Int // winding for thread
    
    var spaceMode : SpaceMode // interconvertible with member of SpaceMode enum
    var laceKind : LaceKind // index in LaceKind structure
    var laceKindWinding : Int // winding for kind
    var pinSpacing : Decimal // the overall separation
    
    /*enum Keys : String, CodingKey {
        case printer
        case printerOrList
        case resolution
        case threadMode
        case material
        case thread
        case threading
        case spaceMode
        case laceKind
        case laceKindWinding
        case pinSpacing
    }
    
    init() {
        printer = 0
        printerOrList = true
        resolution = 300
        
        threadMode = .Library
        material = 0
        thread = 0
        threading = 0
        
        spaceMode = .Kind
        laceKind = .Torchon
        laceKindWinding = 0
        pinSpacing = Decimal()
    } */
    
    static func get<T>(_ d : [String:Any], _ key : String) -> T? {
        d[key] as? T
    }
    
    init(from : [String:Any] = [:]) {
        printer = Self.get(from,"printer") ?? 0
        printerOrList = (Self.get(from,"printerOrList") ?? 0) > 0
        resolution = Self.get(from,"resolution") ?? 300
        
        threadMode = ThreadMode(Self.get(from,"threadMode") ?? 0)
        material = Self.get(from,"material") ?? 0
        thread = Self.get(from,"thread") ?? 0
        threading = Self.get(from,"threading") ?? 0
        
        spaceMode = SpaceMode(Self.get(from,"spaceMode") ?? 0)
        laceKind = LaceKind(Self.get(from,"laceKind") ?? LaceKind.Torchon.rawValue)
        laceKindWinding = Self.get(from,"laceKindWinding") ?? 0
        pinSpacing = Self.get(from,"pinSpacing") ?? Decimal.zero
    }
    
    func code() -> [String:Any] {
        [
            "printer" : printer,
            "printerOrList" : printerOrList ? 1 : 0,
            "resolution" : resolution,
            "threadMode" : threadMode.rawValue,
            "material" : material,
            "thread" : thread,
            "threading" : threading,
            "spaceMode" : spaceMode.rawValue,
            "laceKind" : laceKind.rawValue,
            "laceKindWinding" : laceKindWinding,
            "pinSpacing" : pinSpacing
        ]
    }
 
    /*
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Keys.self)
        printer = try c.decode(Int.self, forKey: .printer)
        printerOrList = try c.decode(Bool.self, forKey: .printerOrList)
        resolution = try c.decode(Int.self, forKey: .resolution)
        
        threadMode = try c.decode(ThreadMode.self, forKey: .threadMode)
        material = try c.decode(Int.self, forKey: .material)
        thread = try c.decode(Int.self, forKey: .thread)
        threading = try c.decode(Int.self, forKey: .threading)
        
        spaceMode = try c.decode(SpaceMode.self, forKey: .spaceMode)
        laceKind = try c.decode(LaceKind.self, forKey: .laceKind)
        laceKindWinding = try c.decode(Int.self, forKey: .laceKindWinding)
        
        pinSpacing = try c.decode(Decimal.self, forKey: .pinSpacing)
    }
    
    func encode(to encoder: Encoder) throws {
        var c=encoder.container(keyedBy: Keys.self)
        try c.encode(printer, forKey: .printer)
        try c.encode(printerOrList, forKey: .printerOrList)
        try c.encode(resolution, forKey: .resolution)
        
        try c.encode(threadMode, forKey: .threadMode)
        try c.encode(material, forKey: .material)
        try c.encode(thread, forKey: .thread)
        try c.encode(threading, forKey: .threading)
        
        try c.encode(spaceMode, forKey: .spaceMode)
        try c.encode(laceKind, forKey: .laceKind)
        try c.encode(laceKindWinding, forKey: .laceKindWinding)
        try c.encode(pinSpacing, forKey: .pinSpacing)
    }
     
     */
    
}

extension LaceState : Nameable, HasDefault {
    public static var zero : LaceState { LaceState() }
    public static func def(_ v : any DefaultPart) -> LaceState { zero }
    public var str : String { "Lace state" }
}

extension LaceState : EncDec {
    
    func enc() -> Any? {
        self.code() as Any
    }
    
    static func dec(_ x : Any) -> LaceState? {
        guard let data = x as? [String:Any] else { return nil }
        return LaceState(from: data)
    }
    
}

class LaceSettingsPanel : NSView, ThreadCalcDelegate, SettingsFacet {
    func load() {
        
    }
    
    func save() throws {
        
    }
    
    
    
    func cleanup() {
    }
    
    
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
    
    var printSystem : PrintSystem?
    var displayedResolutions : [Int] = []
    var firstTime : Bool = true
    
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
            resolutionsButton(nil)
        }
    }
    
    @IBAction func printerAction(_ button: NSPopUpButton!) {
        guard let pr = printSystem?[printers.indexOfSelectedItem] else { return }
        displayedResolutions = pr.resolutions.map { $0.widthI }
        resolutions.removeAllItems()
        resolutions.addItems(withTitles: displayedResolutions.asStrings)
        resolutions.selectItem(at: 0)
        resolutionsButton(nil)
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
            calc.reset()
            
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
        

    }
}
