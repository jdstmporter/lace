//
//  threadListPanel.swift
//  lace
//
//  Created by Julian Porter on 08/01/2023.
//

import AppKit

class ThreadListPanelView : NSPanel, LaunchableItem, NSTableViewDelegate, NSTableViewDataSource {
    static var nibname: NSNib.Name = NSNib.Name("ThreadList")
    
    static var lock: NSLock = NSLock()
    
    
    
    var columns : [NSUserInterfaceItemIdentifier] = []
    var threadset : [FullThreadKind] = []
    typealias TableRow = [NSView?]
    var strings : [[String]] = []
    var rows : [TableRow?] = []
    var initialised : Bool = false
    var count : Int { threadset.count }
    
    @IBOutlet weak var table : NSTableView!
    @IBOutlet weak var search : NSSearchField!
    
    static var threads : ThreadListPanelView? = nil
    
    
    
    @IBAction func closeAction(_ b : NSButton) {
        ThreadListPanelView.close()
    }
    
    @discardableResult static func close() -> ThreadListPanelView? {
        threads?.performClose(nil)
        return threads
    }
    
    static func launch() {
        if threads==nil {
            threads=instance()
            threads?.initialise()
            
        }
        threads?.makeKeyAndOrderFront(nil)
    }
    
    func initialise() {
        guard !initialised else { return }
        
        do {
            let t=try Threads()
            self.threadset = t.list
            self.strings = self.threadset.map { $0.strings }
            self.rows = Array<TableRow?>.init(repeating: nil, count: self.strings.count)
        }
        catch(let e) {
            syslog.error(e.localizedDescription)
            self.threadset.removeAll()
            self.strings.removeAll()
            self.rows.removeAll()
        }
        
        self.columns = self.table.tableColumns.map { $0.identifier }
        self.initialised=true
        
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor col : NSTableColumn?, row: Int) -> Any? {
        guard let col = col,
              let idx = (columns.firstIndex { $0==col.identifier }),
              row>=0 && row<self.threadset.count
        else { return nil }
        syslog.announce(self.threadset[row].strings.description)
        return strings[row][idx]
    }
    func tableView(_ tableView: NSTableView, viewFor col: NSTableColumn?, row: Int) -> NSView? {
        guard let col = col,
              let idx = (columns.firstIndex { $0==col.identifier }),
              row>=0 && row<self.threadset.count
        else { return nil }
        if let views = rows[row] { return views[idx] }
        else {
            let views=strings[row].map { NSTextField(labelWithString: $0) }
            rows[row]=views
            return views[idx]
        }
    }
    func numberOfRows(in tableView: NSTableView) -> Int { self.count }
    
   
    
}
