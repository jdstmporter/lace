//
//  autobackup.swift
//  lace
//
//  Created by Julian Porter on 27/01/2023.
//

import AppKit

class AutoBackupManager {
    static let Interval : TimeInterval = 120.0
    
    var timer : Timer!
    var didChange : Bool = true
    var active : Bool = true
    
    init() {
        timer = Timer(timeInterval: AutoBackupManager.Interval, target: self, selector: #selector(action), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func stop() {
        active=false
        timer.invalidate()
    }
    
    @objc func action(_ timer: Timer) {
        guard active, didChange else { return }
        guard let pricking = NSApplication.controller?.drawingArea.pricking else { return }
        do { try AutoBackup().save(pricking) } catch {}
        didChange=false
    }
}
