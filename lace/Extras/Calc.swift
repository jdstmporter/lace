//
//  Calc.swift
//  lace
//
//  Created by Julian Porter on 27/05/2022.
//

import Foundation

protocol ThreadCalcDelegate {
    var laceKindName : String { get }
    var threadName : String { get }
    var threadIndex : Int { get }
    var material : String { get }
    var searchString : String { get }
    
    var threadWinding : Int { get set }
    var laceKindWinding : Int { get set }
    var pinSpacing : String { get set }
    
    func setThreads(items : [String])
    
    
   
}

class ThreadCalc {
    public typealias Callback = (ThreadInfo) -> ()
    
    public enum ThreadMode {
        case Library
        case Custom
    }
    public enum SpaceMode {
        case Kind
        case CustomKind
        case CustomSpace
    }
    
    public private(set) var info = ThreadInfo()
    public private(set) var selectedMaterial : String = ""
    public private(set) var storedSearch : String = ""
    public private(set) var matchingThreads : Threads.ThreadGroup = []
    public private(set) var matchedThreads : Threads.ThreadGroup = []
    public private(set) var pinSeparation : Decimal?
    
    private var threadMode : ThreadMode = .Library
    private var spaceMode : SpaceMode = .Kind
    
    
    
    public var delegate : ThreadCalcDelegate
    
    public init(_ d : ThreadCalcDelegate) {
        self.delegate=d
    }
    
    public func reset() {
        info = ThreadInfo()
        selectedMaterial = ""
        storedSearch=""
        matchedThreads.removeAll()
        matchingThreads.removeAll()
        pinSeparation=nil
    }
    
    public func setMode(thread: ThreadMode) {
        self.threadMode=thread
    }
    public func setMode(space: SpaceMode) {
        self.spaceMode=space
    }
    
    
    private var changedThread : Bool = false
    
    
    private func doSearch() {
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
    }
    
   
    
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
                guard let kind = LaceKind(selected) else { return }
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
                let f = Float(self.delegate.pinSpacing)
                self.pinSeparation=f?.truncated
            }
        }
            
  
        
    }
    

    
    
    
 
}
