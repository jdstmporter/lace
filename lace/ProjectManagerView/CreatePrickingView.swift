//
//  CreatePrickingView.swift
//  lace
//
//  Created by Julian Porter on 30/04/2023.
//

import Foundation
import AppKit

class CreatePrickingWindow : NSWindow, LaunchableItem {
    typealias Handler = (NSApplication.ModalResponse) -> Void
    enum PrickingError : Error {
        case cancelled
        case unknown
        case nilreturn
    }
    
    static var nibname = NSNib.Name("CreatePrickingWindow")
    static var lock = NSLock()
    
    @IBOutlet var laceKindButton : NSPopUpButton!
    @IBOutlet var name : NSTextField!
    @IBOutlet var width : NSTextField!
    @IBOutlet var height : NSTextField!
    
    var uuid = UUID.Null
    var pricking = PrickingSpec()
    
    func initialise(locked : Bool = false) {
        laceKindButton.load(LaceKind.self)
        self.reset()
        self.name.isEnabled = !locked
        self.name.isEditable = !locked
    }
    
    func reset() {
        self.pricking.reset()
        width.integerValue = self.pricking.width
        height.integerValue = self.pricking.height
        name.stringValue = self.pricking.name
        laceKindButton.selectItem(withTitle: self.pricking.kind.name)
    }
    
    static var window : CreatePrickingWindow? = nil
    static func launch(locked : Bool = false) -> CreatePrickingWindow? {
        if window==nil {
            window=instance()
            window?.initialise(locked : locked)
        }
        return window
    }
    
    
    
    @IBAction func go(_ button : Any) {
        let name = self.name.stringValue
        let width = self.width.integerValue
        let height = self.height.integerValue
        let kind = LaceKind(self.laceKindButton.titleOfSelectedItem)
        
        self.pricking = PrickingSpec(name: name, width: width, height: height, kind: kind)
        self.sheetParent?.endSheet(self, returnCode: .OK)
    }
    
    @IBAction func cancel(_ button : Any) {
        self.pricking.reset()
        self.sheetParent?.endSheet(self, returnCode: .cancel)
    }
    
    
    
    func start(host : NSWindow) async throws -> PrickingSpec {
        return try await withCheckedThrowingContinuation { continuation in
            host.beginSheet(self) { result in
                switch result {
                case .OK:
                    continuation.resume(returning: self.pricking)
                case .cancel:
                    continuation.resume(throwing: PrickingError.cancelled)
                default:
                    continuation.resume(throwing: PrickingError.unknown)
                }
            }
        }
    }
    
    static func start(host : PrickingSpecifier) async throws -> PrickingSpec {
        guard let w=host.window, let win = CreatePrickingWindow.launch(locked: host.isLocked)
        else { throw PrickingError.nilreturn  }
        return try await win.start(host: w)
    }
        
        
//        host.beginSheet(self,completionHandler: self.handler(callback))
 //   }
    
    
}


