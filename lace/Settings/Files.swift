//
//  Files.swift
//  lace
//
//  Created by Julian Porter on 15/04/2022.
//

import Foundation
import AppKit





class LoadSaveFiles {
    
    
    private var urls : ViewPaths = ViewPaths()
    var root: URL { urls[.DataDirectory] }
    
    init() {}
    
    func initialisePaths(_ u : URL) {
        self.urls[.LastPath]=u
        self.urls[.DataDirectory]=u.asDirectory()
    }
    
    func fixDataRoot() throws {
        if !urls.has(.DataDirectory) {    /* need to set path*/
            guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            else { throw FileError.CannotFindBundleIdentifier }
            var p = URL.userHome
            p.appendPathComponent(appName)
            syslog.info("Setting file path to \(p)")
            self.initialisePaths(p)
        }
    }
    
    func fixDataDirectory() throws {
        syslog.debug("Loaded path: \(root)")
        let fm = FileManager.default
        syslog.debug("Checking data directory exists")
        if !fm.fileExists(at: root) {
            syslog.debug("Creating")
            try fm.createDirectory(at: root, withIntermediateDirectories: false)
        }
        syslog.info("Ready with document root \(root)")
    }
    
    func initialise()  throws {
        try fixDataRoot()
        try fixDataDirectory()
    }
    
    //static func RootPath() throws -> URL {
     //   try LoadSaveFiles().root
    //}
    
    
    func load<T>(pick: Bool) throws -> T
    where T : Codable
    {
        if pick {
            let picker = FileReadPicker(def: self.urls[.LastPath])
            guard picker.runSync() else {
                throw FileError.CannotPickLoadFile
            }
            self.urls[.LastPath]=picker.url
        }
        
        
        let d = try Data(contentsOf: self.urls[.LastPath])
        let decoder=JSONDecoder()
        return try decoder.decode(T.self, from: d)
    }
    
    func save<T>(_ data : T,pick: Bool,compact: Bool=true) throws
    where T : Codable
    {
        if pick || !urls.has(.LastPath) {
            let picker = FilePicker(def: self.urls[.LastPath])
            guard picker.runSync() else {
                throw FileError.CannotPickSaveFile
            }
            self.urls[.LastPath]=picker.url
        }
        
        let encoder=JSONEncoder()
        if !compact { encoder.outputFormatting = .prettyPrinted }
        let d = try encoder.encode(data)
        try d.write(to: self.urls[.LastPath])
    }
    
}
