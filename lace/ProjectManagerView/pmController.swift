//
//  popoverWindow.swift
//  lace
//
//  Created by Julian Porter on 22/04/2023.
//

import Foundation
import AppKit

enum ActionChoice {
    case Continue
    case Load(url : URL?)
    case New(width: Int,height: Int)

    case Undefined
}

protocol IMainPage {
    typealias Callback = (ActionChoice) -> Void
    var cb : Callback? { get set }
    func set(callback : Callback)
}

extension IMainPage {
    mutating func set(callback : @escaping Callback) { self.cb=callback }
}



class ProjectManagerController : NSViewController {
    
    
    @IBOutlet weak var tabs: NSTabView!
    
    var dataState = Trivalent<DataHandler>()
    var initialised : Bool = false
    
    func setTab(_ state : DataState = .Unset) {
        self.tabs.selectTabViewItem(at: state.rawValue)
        self.initialised = state != .Unset
    }
    
    func setActiveMode(state: DataState) async {
        await MainActor.run {
            guard !self.initialised else { return }
            self.setTab(state)
        }
    }
    
    func setDataSource(handler: DataHandler?) {
        Task {
            let state = await self.dataState.set(handler)
            await self.setActiveMode(state: state)
        }
    }
    
    func actionResponse(choice: ActionChoice) {}
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvent(_ :)), name: SettingsPanel.DefaultsUpdated, object: nil)
        
        let cb : (ActionChoice) -> Void = { self.actionResponse(choice: $0) }
        var mp = tabs.tabViewItems.compactMap { $0.view as? IMainPage }
        mp.forEach { $0.set(callback: cb) }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        Task {
            let state = await dataState.state
            await self.setActiveMode(state: state)
        }
    }
    
    @objc func updateEvent(_ n : Notification) {
        DispatchQueue.main.async {
            syslog.info("Reloading defaults")
            
        }
    }
}



class NoStorageView : NSView, IMainPage {
    
    var cb : Callback?
    
    @IBAction func didClickOK(_ sender: Any) {
        self.cb?(.Undefined)
    }
    
}


class GotStorageView : NSView, IMainPage {
    
    

    @IBOutlet weak var continuer : NSButton!
    @IBOutlet weak var loader: NSButton!
    @IBOutlet weak var pather: NSPathControl!
    @IBOutlet weak var blanker: NSButton!
    @IBOutlet weak var widther: NSTextField!
    @IBOutlet weak var heighter: NSTextField!
    
    var wid : Int { widther.integerValue }
    var hei : Int { heighter.integerValue }
    
    
    var cb : Callback?
    

    @IBAction func buttonAction(_ sender: NSButton) {
        [self.blanker,self.loader,self.continuer].forEach { $0.state = ($0==sender) ? .on : .off }
    }
    
    @IBAction func go(_ sender: NSButton) {
        var outcome : ActionChoice = .Undefined
        if continuer.state == .on { outcome = .Continue }
        else if loader.state == .on { outcome = .Load(url: pather.url) }
        else  if blanker.state == .on { outcome = .New(width: wid, height: hei) }
        
        self.cb?(outcome)
    }
}

