//
//  popoverWindow.swift
//  lace
//
//  Created by Julian Porter on 22/04/2023.
//

import Foundation
import AppKit

class PopoverWindow : NSWindow, LaunchableItem {
    
    static var nibname: NSNib.Name = NSNib.Name("startup")
    static var lock: NSLock = NSLock()
    
    enum Choice {
        case Continue
        case Load(url: URL?)
        case New(width: Int,height: Int)
        case Accept
        
        var str : String {
            switch self {
            case .Continue:
                return "Continue"
            case .Load(let url):
                return "Load \(url?.relativePath ?? "-")"
            case .New(let width,let height):
                return "New \(width) x \(height)"
            case .Accept:
                return "Accept failure mode"
            }
        
            
        }
        
        var path : URL? {
            switch self {
            case .Load(let url):
                return url
            default:
                return  nil
            }
        }
        var size : GridSize? {
            switch self {
            case .New(let width,let height):
                return GridSize(width,height)
            default:
                return  nil
            }
        }
        
        
    }
    
    
    
    
    @IBOutlet weak var tabs: NSTabView!
    
    enum Mode : Int {
        case Loading = 0
        case Success = 1
        case Failure = 2
    }
    
    func set(mode : Mode) {
            self.tabs?.selectTabViewItem(at: mode.rawValue)
    }
    
    var outcome : PopoverWindow.Choice?
    
    @IBOutlet weak var blanker: NSButton!
    @IBOutlet weak var continuer: NSButton!
    @IBOutlet weak var loader: NSButton!
    @IBOutlet weak var pather: NSPathControl!
    @IBOutlet weak var heighter: NSTextField!
    @IBOutlet weak var width: NSTextField!
    
    func initialise() {
        self.set(mode: .Loading)
        
        let c = FilePaths.hasCurrent
        continuer.isEnabled = c
        if c {
            continuer.state = .on
            pather.url = FilePaths.current
        }
        else {
            blanker.state = .on
            pather.isHidden = true
        }
        
    }
    static var popover : PopoverWindow? = nil
    static func launch() -> PopoverWindow? {
        if popover==nil {
            popover=instance()
            popover?.initialise()
        }
        return popover
    }
    
    
    var wid : Int { width.integerValue }
    var hei : Int { heighter.integerValue }
    
    @IBAction func radioButtons(_ sender: NSButton) {
        [self.blanker,self.loader,self.continuer].forEach { $0.state = ($0==sender) ? .on : .off }
    }
    

    @IBAction func buttonAction(_ sender: NSButton) {
        var outcome : PopoverWindow.Choice? = nil
        if continuer.state == .on { outcome = .Continue }
        else if loader.state == .on { outcome = .Load(url: pather.url) }
        else  if blanker.state == .on { outcome = .New(width: wid, height: hei) }
        
        self.outcome=outcome
        self.sheetParent?.endSheet(self, returnCode: .OK)
        
    }
    
    typealias Handler = (NSApplication.ModalResponse) -> Void
    typealias Callback = (PopoverWindow.Choice?) -> Void
    func handler(_ callback : @escaping Callback) -> Handler {
        { _ in callback(self.outcome) }
    }
    
    func start(_ w: NSWindow,callback: @escaping Callback) {
        w.beginSheet(self,completionHandler: self.handler(callback))
    }
    
    
    @IBAction func failed(_ sender: Any) {
        self.outcome = .Accept
        self.sheetParent?.endSheet(self, returnCode: .OK)
    }
}

