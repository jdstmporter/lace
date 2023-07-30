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
    var show : [Int] = []
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
    
    var range : Range<Int> { 0..<self.count }
    
    @IBAction func searchAction(_ s : NSSearchField) {
        let searchString=self.search.stringValue
        if searchString.count>0 {
            do {
                let regex=try NSRegularExpression(pattern: searchString, options: [.caseInsensitive,.ignoreMetacharacters])
                self.show = self.range.compactMap { idx in
                    let d=self.threadset[idx].description
                    let match = regex.numberOfMatches(in: d, range: NSMakeRange(0, d.count))
                    return (match>0) ? idx : nil
                }
            }
            catch {}
        }
        else {
            self.show = Array(self.range)
        }
        DispatchQueue.main.async {[self] in self.table.reloadData() }
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
        self.show = Array(0..<self.rows.count)
        self.columns = self.table.tableColumns.map { $0.identifier }
        self.initialised=true
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor col : NSTableColumn?, row: Int) -> Any? {
        guard let col = col,
              let idx = (columns.firstIndex { $0==col.identifier }),
              row>=0 && row<self.show.count
        else { return nil }
        let shown=show[row]
        syslog.announce(self.threadset[shown].strings.description)
        return strings[shown][idx]
    }
    func tableView(_ tableView: NSTableView, viewFor col: NSTableColumn?, row: Int) -> NSView? {
        guard let col = col,
              let idx = (columns.firstIndex { $0==col.identifier }),
              row>=0 && row<self.show.count
        else { return nil }
        
        let shown=show[row]
        if let views = rows[shown] { return views[idx] }
        else {
            let views=strings[shown].map { NSTextField(labelWithString: $0) }
            rows[shown]=views
            return views[idx]
        }
    }
    func numberOfRows(in tableView: NSTableView) -> Int { self.show.count }
    
   
    
}
