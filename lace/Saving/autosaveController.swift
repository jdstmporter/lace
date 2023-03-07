//
//  autosaveController.swift
//  lace
//
//  Created by Julian Porter on 07/02/2023.
//

import Foundation

class AutoSaveProcessor {
    
    static var queue : DispatchQueue = DispatchQueue(label: "LaceBackgroundSave", qos: .background)
    
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
        let timer = Timer(timeInterval: interval, repeats: true) { self.timedAction($0) }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func haltTimedBackups() { self.alive=false }
    
    func timedAction(_ tmr : Timer) {
        if !self.alive {
            tmr.invalidate()
            syslog.info("Backup timer stopping")
        }
        else if self.didSet { self._update() }
        self.didSet=false
    }
    
    
    var file : File { File(url: FilePaths.autosave) }
    
    
    
    
    
    func _set(_ pricking: Pricking, immediate: Bool = false) {
        self.pricking=pricking
        if immediate { self._update() }
    }
    
    func _reset() {
        self.pricking=nil
        AutoSaveProcessor.queue.async { [self] in
            try? file.del()
        }
    }
    
    func _update() {
        guard let p=pricking else { return }
        AutoSaveProcessor.queue.async { [self] in
            do { try file.save(p) }
            catch(let e) { syslog.error(e.localizedDescription) }
        }
    }
    
    func _load() -> Pricking? {
        return AutoSaveProcessor.queue.sync { [self] in
            do { return try file.load() }
            catch(let e) {
                syslog.error(e.localizedDescription)
                return nil
            }
        }
    }

    
    static var the = AutoSaveProcessor()
    static func set(pricking p : Pricking, immediate i : Bool = false) {
        the._set(p, immediate: i)
    }
    static func has() -> Bool { the.pricking != nil  }
    static func load() -> Pricking? { the._load() }
    static func reset() { the._reset() }
    
    
    
}

