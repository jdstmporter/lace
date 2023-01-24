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
    
    var root: URL { self.urls.load(.DataDirectory) ?? URL.zero }
    var hasRoot : Bool { urls.has(.DataDirectory) }
    
    var current: URL {
        get { self.urls.load(.FilePath) ?? URL.zero }
        set(u) { urls.save(.FilePath,u.asDirectory()) }
    }
    var hasCurrent : Bool { urls.has(.FilePath) }
    func clearCurrent() { self.urls.del(.FilePath) }
    
    
    private func appName() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "LaceApp"
    }
    
    init() {
        if !self.hasRoot {    /* need to set path*/
            var p = URL.userHome
            p.appendPathComponent(self.appName())
            syslog.info("Setting file path to \(p)")
            self.urls.save(.DataDirectory, p)
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
                self.urls.save(.DataDirectory,URL.userHome)
            }
        }
        syslog.info("Ready with document root \(root)")
        
    }
    
    func setRoot(_ p : URL) {
        syslog.announce("URLS root is \(p)" )
        self.urls[.DataDirectory]=p.asDirectory()
        self.urls.commit()
    }
    func setFile(_ p : URL) {
        self.current=p
        self.commit()
    }
    func existingFile() -> URL { self.current }
    
    
    
    public func commit() { self.urls.commit() }
    
    
    static var the : FilePaths!
    @discardableResult static func load() -> FilePaths {
        if the==nil { the=FilePaths() }
        return the
    }
    public static var root: URL { load().root }
    public static var current: URL { load().current }
    public static var hasCurrent : Bool { load().hasCurrent }
    public static func newFile(_ p : URL) { load().setFile(p) }
    
    public static func shutdown() {
        //load().clearCurrent()
    }
    
    
    
}

struct AutoBackup {
    
    private static func appName() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "LaceApp"
    }
    private static func url() throws -> URL {
        let fm = FileManager.default
        var urlBase = try fm.url(for: .autosavedInformationDirectory,in: .userDomainMask,  appropriateFor: nil, create: true)
        urlBase.appendPathComponent("\(AutoBackup.appName()).backup")
        return urlBase
    }
    
    static func del() throws {
        let fm = FileManager.default
        try fm.removeItem(at: url())
    }
    
    static func load<T>() throws -> T
    where T : Codable {
        let d = try Data(contentsOf: url())
        let decoder=JSONDecoder()
        return try decoder.decode(T.self, from: d)
    }
    
    static func save<T>(_ data : T) throws
    where T : Codable {
        let encoder=JSONEncoder()
        let d = try encoder.encode(data)
        try d.write(to: url())
        
    }
}

struct File {
    
    static func load<T>() throws -> T
    where T : Codable
    {
        let picker = FileReadPicker(def: FilePaths.root)
        guard picker.runSync() else {
            throw FileError.CannotPickLoadFile
        }
        
        let d = try Data(contentsOf: picker.url)
        let decoder=JSONDecoder()
        return try decoder.decode(T.self, from: d)
    }
    
    @discardableResult static func save<T>(_ data : T,compact: Bool=true) throws -> URL
    where T : Codable
    {
        let picker = FilePicker(def: FilePaths.root)
        guard picker.runSync() else {
            throw FileError.CannotPickSaveFile
        }
        try save(url: picker.url,data,compact: compact)
        return picker.url
    }
    
    static func save<T>(url: URL,_ data : T,compact: Bool=true) throws
    where T : Codable
    {
        let encoder=JSONEncoder()
        if !compact { encoder.outputFormatting = .prettyPrinted }
        let d = try encoder.encode(data)
        try d.write(to: url)
    }
    
}
