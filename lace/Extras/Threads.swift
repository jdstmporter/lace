//
//  Threads.swift
//  lace
//
//  Created by Julian Porter on 10/05/2022.
//

import Foundation

class ThreadCalculation {
    public typealias Callback = ([String],Bool,Int,Bool,Int,Float) -> ()
    private enum E : Error { case noSearchTerm }
    
    let regexOpts : NSRegularExpression.Options = [.caseInsensitive,.ignoreMetacharacters]
    
    var threads : Threads.ThreadGroup = []
    var matchedThreads : Threads.ThreadGroup = []
    var material : String = ""
    var searchTerm : String = ""
    var selectedIndex : Int = 0
    var threadWindingIsEditable : Bool = false
    var threadWindingValue : Int = 0
    var selectedKind : String = ""
    var laceKindWindingIsEditable : Bool = false
    var laceKindWindingValue : Int = 0
    var pinSpacingValue : Float = 0.0
    
    var callback : Callback?
    
    enum Stage {
        case Material
        case Search
        case Thread
        case Kind
        case Final
    }
    var spacingInMM : Float { 10.0*Float(self.laceKindWindingValue)/Float(self.threadWindingValue) }
    
    func cascade(stage: Stage) {
        switch stage {
        case .Material:    // reload
            self.threads = Threads.group(material)
            self.cascade(stage: .Search)
        case .Search:
                do {
                    guard searchTerm.count>0 else { throw E.noSearchTerm }
                    let regex=try NSRegularExpression(pattern: searchTerm, options: regexOpts)
                    let t=self.threads.filter { thread in
                        let d = thread.description
                        return regex.numberOfMatches(in: d, range: NSMakeRange(0, d.count)) > 0
                    }
                    self.matchedThreads=t
                }
                catch {
                    self.matchedThreads=Array(self.threads)
                }
            self.cascade(stage: .Thread)
        case .Thread:
            let editable = selectedIndex>=self.matchedThreads.count
            let n = (editable) ? 1 : self.matchedThreads[selectedIndex].wraps
                
            self.threadWindingIsEditable=editable
            self.threadWindingValue=n
            self.cascade(stage: .Kind)
        case .Kind:
            let kind = LaceStyle(selectedKind)
            let editable = kind == .Custom
            let n = kind.wrapsPerSpace
            self.laceKindWindingIsEditable=editable
            self.laceKindWindingValue=n
            self.cascade(stage: .Final)
        case .Final:
            if self.threadWindingValue>0 && self.laceKindWindingValue>0 {
                self.pinSpacingValue=self.spacingInMM.truncated(nDecimals: 1)
            }
            let n=self.matchedThreads.map { $0.description }
            callback?(n,self.threadWindingIsEditable,self.threadWindingValue,self.laceKindWindingIsEditable,self.laceKindWindingValue,self.pinSpacingValue)
            return
        }
            
            
    }
    
    
    func setMaterial(_ m : String = "") {
        material=m
        self.cascade(stage: .Material)
    }
    func setSearchTerm(_ s : String = "") {
        searchTerm=s
        self.cascade(stage: .Search)
    }
    func setThreadIndex(_ i : Int = 0) {
        selectedIndex=i
        self.cascade(stage: .Thread)
    }
    func setLaceKind(_ k : String = "") {
        selectedKind=k
        self.cascade(stage: .Kind)
    }
    func setThreadWinding(_ w : Int) {
        self.threadWindingValue=w
        self.cascade(stage: .Final)
    }
    func setLaceKindWinding(_ w : Int) {
        self.laceKindWindingValue=w
        self.cascade(stage: .Final)
    }
    
    func initialise() { self.cascade(stage: .Material) }
    
    
}
