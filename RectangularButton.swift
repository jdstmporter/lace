//
//  RectangularButton.swift
//  lace
//
//  Created by Julian Porter on 22/01/2023.
//

import AppKit

fileprivate let decodes : [NSEvent.SpecialKey : String] = [
    .backspace : "backspace",
    .carriageReturn : "CR",
    .newline : "newline",
    .enter : "enter",
    .delete : "DEL",
    .deleteForward : "DEL FWD",
    .backTab : "back tab",
    .tab : "tab"
]



@IBDesignable
class RectangularButton : NSTextField {
    

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
  
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseUp(with event: NSEvent) {
        syslog.announce("Mouse up inside")
        self.sendAction(self.action, to: self.target)
    }
    override func keyDown(with event: NSEvent) {
        guard let key = event.specialKey else { return }
        let s = decodes[key] ?? "-"
        syslog.announce("Key is \(s)")
    }
    
    
    
}
