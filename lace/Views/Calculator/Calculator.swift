//
//  Calculator.swift
//  lace
//
//  Created by Julian Porter on 10/05/2022.
//

import Foundation
import AppKit


class ThreadCalculatorView : NSView {
    typealias Callback = (ThreadInfo) -> ()
    
    enum Stage {
        case Material
        case Search
        case Thread
        case Kind
        case Final
    }
    
    @IBOutlet weak var materials : NSPopUpButton!
    @IBOutlet weak var search : NSSearchField!
    @IBOutlet weak var nResults : NSTextField!
    @IBOutlet weak var threads : NSPopUpButton!
    @IBOutlet weak var threadWinding : NSTextField!
    @IBOutlet weak var laceKind : NSPopUpButton!
    @IBOutlet weak var laceKindWinding : NSTextField!
    @IBOutlet weak var pinSpace : NSTextField!
    
    var matchingThreads : Threads.ThreadGroup = []
    var matchedThreads : Threads.ThreadGroup = []
    var selectedMaterial : String = ""
    var callback : Callback?
    
    //var laceKindValue = LaceKindWithWindingCount()
    //var threadKindValue = ThreadKind()
    var info = ThreadInfo()
    
    var laceKindName : String { laceKind.titleOfSelectedItem ?? "" }
    var threadName : String { threads.titleOfSelectedItem ?? "" }
    
    func cascade(stage : Stage) {
        switch stage {
        case .Material:
            let selected = materials.titleOfSelectedItem ?? ""
            if selected != self.selectedMaterial {      // reload
                self.matchingThreads = Threads.group(selected)
                let matching = matchingThreads.map { $0.description }
                self.threads.removeAllItems()
                self.threads.addItems(withTitles: matching)
                self.threads.addItem(withTitle: "Custom")
                self.threads.selectItem(at: 0)
            }
            self.selectedMaterial=selected
            self.info.material=selected
            self.cascade(stage: .Search)
        case .Search:
            let searchString=self.search.stringValue
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
            self.nResults.stringValue="\(self.matchedThreads.count) matched"
            let matching = matchedThreads.map { $0.description }
            self.threads.removeAllItems()
            self.threads.addItems(withTitles: matching)
            self.threads.addItem(withTitle: "Custom")
            self.threads.selectItem(at: 0)
            self.cascade(stage: .Thread)
        case .Thread:
            let selected = threads.indexOfSelectedItem
            let editable = selected>=self.matchedThreads.count
            let t = editable ? nil : self.matchedThreads[selected]
            self.info.laceKindName=t?.description ?? "Custom"
            self.info.threadWraps = t?.wraps ?? 1

            self.threadWinding.isEditable=editable
            self.threadWinding.integerValue=self.info.threadWraps
            self.cascade(stage: .Kind)
        case .Kind:
            guard let selected = laceKind.titleOfSelectedItem else { return }
            let kind = LaceKind(selected)
            let editable = kind == .Custom
            let n = kind.wrapsPerSpace
            laceKindWinding.isEditable=editable
            laceKindWinding.integerValue=n
            
            info.laceKind=kind
            if editable { info.laceKindWraps=n }
            
            self.cascade(stage: .Final)
        case .Final:
            self.info.threadWraps=threadWinding.integerValue
            self.info.laceKindWraps=laceKindWinding.integerValue
            if self.info.threadWraps>0, self.info.laceKindWraps>0 {
                let v = self.info.pinSpacing
                pinSpace.stringValue=v.description
            }
            
            
            self.callback?(info)
            return
        }
        
    }
    
    @IBAction func materialsAction(_ popup : NSPopUpButton!) {
        DispatchQueue.main.async { self.cascade(stage: .Material) }
    }
    
    @IBAction func threadsAction(_ popup : NSPopUpButton!) {
        DispatchQueue.main.async { self.cascade(stage: .Thread) }
    }
    @IBAction func laceKindAction(_ popup : NSPopUpButton!) {
        DispatchQueue.main.async { self.cascade(stage: .Kind) }
    }
    
    @IBAction func searchAction(_ s : NSSearchField!) {
        DispatchQueue.main.async { self.cascade(stage: .Search) }
    }
    
    @IBAction func threadWindingAction(_ box : NSTextField!) {
        DispatchQueue.main.async { self.cascade(stage: .Final) }
        
    }
    @IBAction func laceKindWindingAction(_ box : NSTextField!) {
        DispatchQueue.main.async { self.cascade(stage: .Final) }
    }
    
    func initialise() {
        
        // initialise menus
        
        let mk = Threads.groups()
        materials.removeAllItems()
        materials.addItems(withTitles: mk)
        materials.addItem(withTitle: "Custom")
        
        let items = LaceKind.allCases.map { $0.name }
        laceKind.removeAllItems()
        laceKind.addItems(withTitles: items)
        
        self.cascade(stage: .Material)
    }
    
    
}



class ThreadCalculator : NSPanel, LaunchableItem {
    typealias Callback = (String,String,Float) -> ()
    
    static var nibname: NSNib.Name = "Calculator"
    
    static var lock: NSLock = NSLock()
    static var panel: ThreadCalculator? = nil
    
    @IBOutlet weak var view: ThreadCalculatorView!
    
    
    static func launch() -> ThreadCalculator? {
        if panel==nil {
            panel=instance()
            panel?.initialise()
        }
        panel?.makeKeyAndOrderFront(nil)
        return panel
    }
    
    @discardableResult static func close() -> ThreadCalculator? {
        guard let p=panel else { return nil }
        let release = p.isReleasedWhenClosed
        p.performClose(nil)
        if release { panel=nil }
        return panel
    }
    
    
    @discardableResult func initialise() -> ThreadCalculatorView {
        view.initialise()
        return view
    }
    
    
}
