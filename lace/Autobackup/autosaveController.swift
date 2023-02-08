//
//  autosaveController.swift
//  lace
//
//  Created by Julian Porter on 07/02/2023.
//

import Foundation

class AutoSaveProcessor {
    
    static var KEY : String {
        let prefix = Bundle.main.bundleIdentifier ?? ""
        return "\(prefix).backup"
    }
    
    var alive : Bool
    var didSet : Bool = false
    var interval : TimeInterval
    var pricking : Pricking? {
        didSet { self.didSet = true }
    }
    
    init(interval : TimeInterval = 60.0) {
        self.interval=interval
        self.alive=false
    }
    
    func startTimedBackups() {
        self.alive=true
        var timer = Timer(timeInterval: interval, repeats: true) { self.timedAction($0) }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func haltTimedBackups() { self.alive=false }
    
    func timedAction(_ tmr : Timer) {
        if !self.alive {
            tmr.invalidate()
            syslog.info("Backup timer stopping")
        }
        else if self.didSet { self._save() }
        self.didSet=false
    }
    
    
    
    func _save() {
        guard let pricking=self.pricking else { return }
        do {
            try Defaults.write(AutoSaveProcessor.KEY,pricking)
        }
        catch(let e) { syslog.error(e.localizedDescription) }
    }
    @discardableResult func _load() -> Pricking? {
        do { self.pricking = try Defaults.read(AutoSaveProcessor.KEY) }
        catch(let e) {
            self.pricking=nil
            syslog.error(e.localizedDescription)
        }
        return self.pricking
    }
    
    func _has() -> Bool {
        self.pricking != nil
    }
    
    func _new() {
        self.pricking=nil
        Defaults.remove(forKey: AutoSaveProcessor.KEY)
    }
    
    static var the = AutoSaveProcessor()
    static func set(pricking p : Pricking) { the.pricking=p }
    static func has() -> Bool { the._has() }
    static func new() { the._new() }
    static func load() -> Pricking? { the._load() }
    static func save() { the._save() }
    static func save(_ p : Pricking) {
        the.pricking=p
        the._save()
    }
    
    
    
}

