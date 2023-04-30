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
    mutating func set(callback : @escaping Callback)
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


class GotStorageView : NSView, NSTableViewDelegate, NSTableViewDataSource, IMainPage, NSTextFieldDelegate {
    
    @IBOutlet var prickings : NSTableView!

    static let cellID = NSUserInterfaceItemIdentifier("Prickings")
    
    
    var cb : Callback?
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
        self.action(data[row],isNew: false)
    }
    
    @IBAction func createNew(_ sender : Any) {
        guard let w=self.window else { return }
        CreatePrickingWindow.launch()?.start(host: w, callback: { p in self.action(p,isNew: true) })
    }
    
    func action(_ p : PrickingSpecification?,isNew: Bool) {
        guard let pricking = p else { return }
        
        // get corresponding item from DB or create new
    }
}

