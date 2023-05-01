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
        
        laceKindButton.state = .on
        let items = LaceKind.allCases.map { $0.name }
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
        var name = self.name.stringValue
        var width = self.width.integerValue
        var height = self.height.integerValue
        var kind = LaceKind(self.laceKindButton.titleOfSelectedItem)
        
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


