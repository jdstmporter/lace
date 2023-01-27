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
    
    //var root: URL { self.urls.load(.DataDirectory) ?? URL.zero }
    //var hasRoot : Bool { urls.has(.DataDirectory) }
    
    //var current: URL {
    //    get { self.urls.load(.FilePath) ?? URL.zero }
    //    set(u) { urls.save(.FilePath,u.asDirectory()) }
    //}
    //var hasCurrent : Bool { urls.has(.FilePath) }
    //func clearCurrent() { self.urls.del(.FilePath) }
    
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
    
    
    private func appName() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "LaceApp"
    }
    
    private func defaultPath(for dir: PathPart) -> URL {
        switch dir {
        case .DataDirectory, .FilePath:
            var p = URL.userHome
            p.appendPathComponent(self.appName())
            return p
        case .AutoSave:
            do {
                let fm = FileManager.default
                var p = try fm.url(for: .autosavedInformationDirectory,in: .userDomainMask,  appropriateFor: nil, create: true)
                p.appendPathComponent(self.appName())
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
            do {
                try fm.createDirectory(at: self[path], withIntermediateDirectories: false)
            }
            catch {
                self[path]=URL.userHome
            }
        }
        /*
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
        */
    }
    /*
    func setRoot(_ p : URL) {
        syslog.announce("URLS root is \(p)" )
        self.urls[.DataDirectory]=p.asDirectory()
        self.commit()
    }
    func setFile(_ p : URL) {
        self.current=p
        self.commit()
    }
    func existingFile() -> URL { self.current }
    
    
    
    public func commit() { self.urls.commit() }
    */
    
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

protocol DataStorage {
    static func load<T>() throws -> T where T : Codable
    @discardableResult static func save<T>(_ data : T) throws -> URL where T : Codable
    static func del() throws
}
extension DataStorage {
    public static func del() throws {}
}

struct AutoBackup {
    
    static let name : String = "lace.bak.json"
    
    static var url : URL {
        var p = FilePaths.autosave
        p.appendPathComponent(name)
        return p
    }
    
    static func del() throws {
        let fm = FileManager.default
        try fm.removeItem(at: url)
    }
    
    static func load<T>() throws -> T
    where T : Codable {
        let d = try Data(contentsOf: url)
        let decoder=JSONDecoder()
        return try decoder.decode(T.self, from: d)
    }
    
    @discardableResult static func save<T>(_ data : T) throws -> URL
    where T : Codable {
        let encoder=JSONEncoder()
        let d = try encoder.encode(data)
        try d.write(to: url)
        return url
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
