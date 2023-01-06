//
//  Calc.swift
//  lace
//
//  Created by Julian Porter on 27/05/2022.
//

import Foundation





public protocol ThreadCalcDelegate {
    var laceKindName : String { get set }
    var threadName : String { get set }
    var threadIndex : Int { get }
    var material : String { get set }
    var searchString : String { get }
    
    var threadWinding : Int { get set }
    var laceKindWinding : Int { get set }
    var pinSpacing : String { get set }
    var pinSpacingFloat : Float { get }
    
    func setThreads(items : [String])
    func reset()
    
    var threadMode : ThreadMode { get set }
    var spaceMode : SpaceMode { get set }
    
    var printerOrList : ResolutionMode { get set }
    var printer : String { get set }
    var resolution : Int { get set }
    
    var dict : [String:Any] { get set }
}

extension ThreadCalcDelegate {
    
    public var dict : [String:Any] {
        get {
            var d = [String:Any]()
            d["laceKindName"]=laceKindName
            d["threadName"]=threadName
            d["material"]=material
            d["threadWinding"]=threadWinding
            d["lacekindWinding"]=laceKindWinding
            d["pinSpacing"]=pinSpacing
            d["threadMode"]=threadMode.rawValue
            d["spaceMode"]=spaceMode.rawValue
            return d
        }
        set(d) {
            laceKindName=d["laceKindName"] as? String ?? ""
            threadName=d["threadName"] as? String ?? ""
            material=d["material"] as? String ?? ""
            threadWinding=d["threadWinding"] as? Int ?? 0
            laceKindWinding=d["laceKindWinding"] as? Int ?? 0
            pinSpacing=d["pinSpacing"] as? String ?? ""
            threadMode = ThreadMode(d["threadMode"] as? Int ?? 0)
            spaceMode = SpaceMode(d["spaceMode"] as? Int ?? 0)
        }
    }
}

fileprivate class ThreadCalcDelegateDummy : ThreadCalcDelegate {

    var laceKindName : String { get { "" } set {} }
    var threadName : String { get { "" } set {} }
    var threadIndex : Int { 0 }
    var material : String { get { "" } set {} }
    var searchString : String { "" }
    
    var threadWinding : Int { get { 0 } set {} }
    var laceKindWinding : Int { get{ 0 } set {} }
    var pinSpacing : String { get { "" } set {} }
    var pinSpacingFloat : Float { 0 }
    
    var threadMode: ThreadMode { get { .Library} set {} }
    var spaceMode: SpaceMode { get { .Kind}  set {} }
    var printerOrList: ResolutionMode { get { .List } set {} }
    var printer: String { get {""} set {} }
    var resolution : Int { get {0} set {}}
    
    func setThreads(items : [String]) {}
    func reset() {}
}

class ThreadCalc {
    public typealias Callback = (ThreadInfo) -> ()
    public static let SettingsKey = "printingDefaults"
    
    
    public private(set) var info = ThreadInfo()
    public private(set) var selectedMaterial : String = ""
    public private(set) var storedSearch : String = ""
    public private(set) var matchingThreads : Threads.ThreadGroup = []
    public private(set) var matchedThreads : Threads.ThreadGroup = []
    public private(set) var pinSeparation : Decimal = 0
    
    public private(set) var threadMode : ThreadMode = .Library
    public private(set) var spaceMode : SpaceMode = .Kind
    
    public var delegate : ThreadCalcDelegate
    
    public init() {
        self.delegate=ThreadCalcDelegateDummy()
    }
    public init(_ d : ThreadCalcDelegate) {
        self.delegate=d
    }
    
    public func reset() {
        info = ThreadInfo()
        delegate.reset()
        self.loadSettings()
        
        
        selectedMaterial = ""
        storedSearch=""
        matchedThreads.removeAll()
        matchingThreads.removeAll()
        pinSeparation=0
    }
    
    public func setMode(thread: ThreadMode) {
        self.threadMode=thread
    }
    public func setMode(space: SpaceMode) {
        self.spaceMode=space
    }
    
    
    private var changedThread : Bool = false
    
    
    
    
   
    
    enum Stage {
        case Material
        case Search
        case Thread
        case Lace
        case Space
    }
    
    
    func threadAction(_ stage: Stage = .Material) {
        
        switch stage {
        case .Material:
            switch threadMode {
            case .Library:
                let selected = delegate.material
                if selected != selectedMaterial {
                    self.matchingThreads = Threads.group(selected)
                    let matching = matchingThreads.map { $0.description }
                    self.delegate.setThreads(items: matching)
                        
                    self.selectedMaterial=selected
                    self.info.material=selected
                }
            case .Custom:
                break
            }
            self.threadAction(.Search)
        case .Search:
            switch threadMode {
            case .Library:
                let searchString=self.delegate.searchString
                if searchString.count>0 {
                    do {
                        let regex=try NSRegularExpression(pattern: searchString, options: [.caseInsensitive,.ignoreMetacharacters])
                        let t=self.matchingThreads.filter { thread in
                            let d = thread.description
                            return regex.numberOfMatches(in: d, range: NSMakeRange(0, d.count)) > 0
                        }
                        self.matchedThreads=t
                    }
                    catch {}
                }
                else {
                    self.matchedThreads=Array(self.matchingThreads)
                }
                let matching = matchedThreads.map { $0.description }
                self.delegate.setThreads(items: matching)
                self.storedSearch=searchString
            case .Custom:
                break
            }
            self.threadAction(.Thread)
    case .Thread:
        switch threadMode {
        case .Library:
            guard self.matchedThreads.count>0 else { return }
            let sel = self.delegate.threadIndex.clip(0,self.matchedThreads.count-1)
            let t = self.matchedThreads[sel]
            self.info.threadName=t.description
            self.info.threadWraps = t.wraps
            self.delegate.threadWinding=self.info.threadWraps
        case .Custom:
            self.info.threadName="Custom"
            self.info.threadWraps=self.delegate.threadWinding
        }
        self.threadAction(.Lace)
        
        case .Lace:
            switch spaceMode {
            case .Kind:
                let selected = delegate.laceKindName
                let kind = LaceKind(selected)
                self.delegate.laceKindWinding = kind.wrapsPerSpace
                info.laceKind=kind
            case .CustomKind:
                info.laceKind = .Custom
                info.laceKindWraps = self.delegate.laceKindWinding
            case .CustomSpace:
                break
            }
            self.threadAction(.Space)
            
        case .Space:
            switch spaceMode {
            case .Kind, .CustomKind:
                if self.info.threadWraps>0, self.info.laceKindWraps>0 {
                    let v = self.info.pinSpacing
                    self.delegate.pinSpacing=v.description
                    self.pinSeparation=v
                }
            case .CustomSpace:
                self.pinSeparation = self.delegate.pinSpacingFloat.truncated
            }
            print("Set pin separation to \(self.pinSeparation)")
        }
        self.saveSettings()
    }
    
    internal func saveSettings() {
        let defs = self.delegate.dict
        Defaults.set(forKey: ThreadCalc.SettingsKey, value: defs)
    }
    internal func loadSettings() {
        if let defs : [String:Any] = Defaults.get(forKey: ThreadCalc.SettingsKey) {
            self.delegate.dict=defs
        }
    }
    
    
    

    
    
    
 
}
