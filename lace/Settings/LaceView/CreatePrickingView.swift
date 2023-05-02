//
//  CreatePrickingView.swift
//  lace
//
//  Created by Julian Porter on 30/04/2023.
//

import Foundation
import AppKit

class CreatePrickingWindow : NSWindow, LaunchableItem {
    typealias Callback = (PrickingSpecification?) -> Void
    typealias Handler = (NSApplication.ModalResponse) -> Void
    
    static var nibname = NSNib.Name("CreatePrickingWindow")
    static var lock = NSLock()
    
    @IBOutlet var laceKindButton : NSPopUpButton!
    @IBOutlet var name : NSTextField!
    @IBOutlet var width : NSTextField!
    @IBOutlet var height : NSTextField!
    
    var pricking : PrickingSpecification?
    
    func initialise() {
        
        
        let items = LaceKind.allCases.map { $0.name }
        laceKindButton.removeAllItems()
        laceKindButton.addItems(withTitles: items)
        laceKindButton.selectItem(at: LaceKind.Torchon.index)
        
        width.integerValue = 1
        height.integerValue = 1
        name.stringValue = Date.now.slug
    }
    
    static var window : CreatePrickingWindow? = nil
    static func launch() -> CreatePrickingWindow? {
        if window==nil {
            window=instance()
            window?.initialise()
        }
        return window
    }
    
    
    
    @IBAction func go(_ button : Any) {
        let name = self.name.stringValue
        let width = self.width.integerValue
        let height = self.height.integerValue
        let kind = LaceKind(self.laceKindButton.titleOfSelectedItem)
        
        self.pricking = PrickingSpecification(name: name, width: width, height: height, kind: kind)
        self.sheetParent?.endSheet(self, returnCode: .OK)
    }
    
    @IBAction func cancel(_ button : Any) {
        self.pricking=nil
        self.sheetParent?.endSheet(self, returnCode: .cancel)
    }
    
    func handler(_ callback : @escaping Callback) -> Handler {
        { _ in callback(self.pricking) }
    }
    
    func start(host: NSWindow, callback: @escaping Callback) {
        host.beginSheet(self,completionHandler: self.handler(callback))
    }
    
    
}


