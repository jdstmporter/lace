//
//  Files.swift
//  lace
//
//  Created by Julian Porter on 15/04/2022.
//

import Foundation
import AppKit



class FileRoot {
    private var urls : ViewPaths = ViewPaths()
    
    var root: URL { urls[.DataDirectory] }
    var hasRoot : Bool { ViewPaths().has(.DataDirectory) }
    
    public func update(root u : URL) {
        self.urls[.DataDirectory]=u.asDirectory()
        self.commit()
    }
    
    private func appName() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "LaceApp"
    }
    
    init() {
        if !self.hasRoot {    /* need to set path*/
            var p = URL.userHome
            p.appendPathComponent(self.appName())
            syslog.info("Setting file path to \(p)")
            self.update(root: p)
        }
        
        syslog.debug("Loaded path: \(root)")
        let fm = FileManager.default
        syslog.debug("Checking data directory exists")
        if !fm.fileExists(at: root) {
            syslog.debug("Creating")
            do {
                try fm.createDirectory(at: root, withIntermediateDirectories: false)
            }
            catch {
                // default fallback
                self.update(root: URL.userHome)
            }
        }
        syslog.info("Ready with document root \(root)")
        
    }
    
    
    
    public func commit() { self.urls.commit() }
    
    
    static var the : FileRoot!
    static func load() -> FileRoot {
        if the==nil { the=FileRoot() }
        return the
    }
    public static var path: URL { load().root }
    
    
    
}

struct File {
    
    static func load<T>() throws -> T
    where T : Codable
    {
        let picker = FileReadPicker(def: FileRoot.path)
        guard picker.runSync() else {
            throw FileError.CannotPickLoadFile
        }
        
        let d = try Data(contentsOf: picker.url)
        let decoder=JSONDecoder()
        return try decoder.decode(T.self, from: d)
    }
    
    static func save<T>(_ data : T,compact: Bool=true) throws
    where T : Codable
    {
        let picker = FilePicker(def: FileRoot.path)
        guard picker.runSync() else {
            throw FileError.CannotPickSaveFile
        }
        
        let encoder=JSONEncoder()
        if !compact { encoder.outputFormatting = .prettyPrinted }
        let d = try encoder.encode(data)
        try d.write(to: picker.url)
    }
    
}
