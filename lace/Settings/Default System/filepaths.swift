//
//  Files.swift
//  lace
//
//  Created by Julian Porter on 15/04/2022.
//

import Foundation
import AppKit



class FilePaths {
    private var urls : ViewPaths = ViewPaths()

    private func has(_ path : PathPart) -> Bool { urls.has(path) }
    public subscript(_ path : PathPart) -> URL {
        get { self.urls.load(path) ?? URL.zero }
        set(u) {
            self.urls.save(path,u.asDirectory())
            self.urls.commit()
        }
    }
    public func clear(_ path: PathPart) {
        self.urls.del(path)
    }
  
    private func defaultPath(for dir: PathPart) -> URL {
        let appName = Bundle.appName ?? "LaceApp"
        switch dir {
        case .DataDirectory, .FilePath:
            var p = URL.userHome
            p.appendPathComponent(appName)
            return p
        case .AutoSave:
            do {
                var p = try URL.autoSaveRoot
                p.appendPathComponent(appName)
                return p
            }
            catch {
                return URL.userHome
            }
        }
    }
    
    init() {
        let fm = FileManager.default
        [PathPart.DataDirectory,PathPart.AutoSave].forEach { path in
            if !self.has(path) {
                let p=self.defaultPath(for: path)
                self[path]=p
            }
            do { try fm.createDirectory(at: self[path], withIntermediateDirectories: false) }
            catch { self[path]=URL.userHome }
        }
    }
    
    static var the : FilePaths!
    @discardableResult static func load() -> FilePaths {
        if the==nil { the=FilePaths() }
        return the
    }
    public static var root: URL { load()[.DataDirectory] }
    public static var autosave : URL { load()[.AutoSave] }
    public static var current: URL { load()[.FilePath] }
    
    public static var hasCurrent : Bool { load().has(.FilePath) }
    public static func newFile(_ p : URL) { load()[.FilePath]=p }
    
    
    public static func shutdown() {
        //load().clearCurrent()
    }
}



