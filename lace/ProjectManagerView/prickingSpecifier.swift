//
//  prickingSpecifier.swift
//  lace
//
//  Created by Julian Porter on 02/05/2023.
//

import Foundation
import AppKit

class PrickingSpecifier : NSControl {
    
    var pricking = PrickingSpecification()
    
    var isLocked : Bool { false }
    
    @IBAction func createNew(_ sender : Any) {
        guard let w=self.window else { return }
        CreatePrickingWindow.launch(locked: self.isLocked)?.start(host: w, callback: { p in self.cb(p,isNew: true) })
    }
    
    func cb(_ p : PrickingSpecification?,isNew: Bool) {
        self.pricking = p ?? PrickingSpecification()
        guard let s = self.action else { return }
        _ = self.target?.perform(s, with: self)
        
        // get corresponding item from DB or create new
        
    }
    
    
}


class NoStorageView : PrickingSpecifier {
    
    override var isLocked: Bool { true }
    
}


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
            v.font = NSFont.systemFont(ofSize: 10)
            v.identifier = GotStorageView.cellID
            return v
        }
    }
    
    func indexOf(column c: NSTableColumn?) -> Int {
        guard let column=c else { return 0 }
        return prickings.tableColumns.firstIndex(of: column) ?? 0
        
    }
    
    func sizeFor(view : NSTextField,column: NSTableColumn?) -> NSSize {
        guard let id = column?.identifier.rawValue else { return NSSize() }
        guard let box = view.font?.boundingRectForFont else { return NSSize() }
        var width = 0.0
        switch id {
        case "width", "height":
            width =  4*box.width
        case "kind":
            width =  20*box.width
        case "name":
            width =  self.prickings.width-28*box.width
        default:
            width = 0
        }
        return NSSize(width: width, height: box.height+2)
    }
    
    // NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int { self.data.count }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let value = self.tableView(tableView, objectValueFor: tableColumn,row: row) else { return nil }
        let view = self.getView(row: row, column: tableColumn)
        view.stringValue="\(value)"
        let size = self.sizeFor(view: view, column: tableColumn)
        view.setFrameSize(size)
        return view
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let column = tableColumn?.identifier.rawValue else { return nil }
        guard row>=0 && row<data.count  else { return nil }
        
        return data[row][column]
    }
    
    // NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        false
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { 16.0 }
    
    
    
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
        let pricking = data.at(row)
        self.cb(pricking,isNew: false)
    }
    
}

extension Array {
    
    var range : Range<Int> { 0..<self.count }
    
    func at(_ n : Int) -> Element? { self.range.contains(n) ? self[n] : nil }
}

