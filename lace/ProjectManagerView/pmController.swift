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





class ProjectManagerController : NSViewController, NSTabViewDelegate {
    
    
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
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        guard let item = tabViewItem else { return }
        let idx = self.tabs.indexOfTabViewItem(item)
        guard idx != NSNotFound else { return }
        
        
    }
    
    @IBAction func actionResponse(_ from: Any) {
        guard let view=self.tabs.selectedTabViewItem?.view else { return }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvent(_ :)), name: SettingsPanel.DefaultsUpdated, object: nil)
        
        
        
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


class PrickingSpecifier : NSControl {
    
    var pricking = PrickingSpecification()
    
    
    @IBAction func createNew(_ sender : Any) {
        guard let w=self.window else { return }
        CreatePrickingWindow.launch()?.start(host: w, callback: { p in self.cb(p,isNew: true) })
    }
    
    func cb(_ p : PrickingSpecification?,isNew: Bool) {
        self.pricking = p ?? PrickingSpecification()
        guard let s = self.action else { return }
        _ = self.target?.perform(s, with: self)
        
        // get corresponding item from DB or create new
        
    }
    
    
}


class NoStorageView : PrickingSpecifier {}


class GotStorageView : PrickingSpecifier, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    @IBOutlet var prickings : NSTableView!
    

    static let cellID = NSUserInterfaceItemIdentifier("Prickings")
    
    

    var data : [PrickingSpecification] = []
    
    
    
    
    func initialise() {
        data = []
        
        
    }
    
    func getView(row : Int, column: NSTableColumn?) -> NSTextField {
        if let v = prickings.makeView(withIdentifier: GotStorageView.cellID, owner: self) as? NSTextField { return v}
        else {
            let v = NSTextField(labelWithString: "dummy")
            v.identifier = GotStorageView.cellID
            return v
        }
    }
    
    func indexOf(column c: NSTableColumn?) -> Int {
        guard let column=c else { return 0 }
        return prickings.tableColumns.firstIndex(of: column) ?? 0
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int { self.data.count }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let value = self.tableView(tableView, objectValueFor: tableColumn,row: row) else { return nil }
        let view = self.getView(row: row, column: tableColumn)
        view.stringValue="\(value)"
        return view
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let column = tableColumn?.identifier.rawValue else { return nil }
        guard row>=0 && row<data.count  else { return nil }
        
        return data[row][column]
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        false
    }
    
    // context menu
    
    @IBAction func contextAction(_ sender: NSMenuItem) {
        let name = sender.title
        switch name {
        case "Open":
            break
        case "Edit":
            break
        case "Delete":
            break
        default:
            break
        }
    }
    
    

    @IBAction func onDoubleClick(_ sender: Any) {
    }
    
    @IBAction func onClick(_ sender: Any) {
        let row = self.prickings.selectedRow
        self.cb(data[row],isNew: false)
    }
    
}

