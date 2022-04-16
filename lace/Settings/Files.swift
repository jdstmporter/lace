//
//  Files.swift
//  lace
//
//  Created by Julian Porter on 15/04/2022.
//

import Foundation
import AppKit

enum FileError : Error {
    case CannotFindBundleIdentifier
    case CannotCreateDataDirectory
    case CannotPickLoadFile
    case CannotPickSaveFile
}

class LoadSaveFiles {
    
    let root : URL
    
    
    var lastPath : String {
        get {
            let s : String? = Defaults()["LastPath"]
            return s ?? self.root.path
        }
        set { Defaults()["LastPath"]=newValue }
    }
    var isLastPathSet : Bool {
        let s : String? = Defaults()["LastPath"]
        return s != nil
    }
    
    init()  throws {
       
        var path : String? = Defaults()["DataDirectory"]
        print("Loaded path: \(path ?? "nil")")
        if path == nil {    /* need to set path*/
            guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            else { throw FileError.CannotFindBundleIdentifier }
            var userHome = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
            userHome.appendPathComponent(appName)
            path = userHome.path
            print("Setting path to \(path!)")
            Defaults()["DataDirectory"]=path!
        }
        let fm = FileManager.default
        print("Checking data directory exists")
        if !fm.fileExists(atPath: path!) {
            print("Creating")
            try fm.createDirectory(atPath: path!, withIntermediateDirectories: false)
        }
        
        self.root=URL(fileURLWithPath: path!, isDirectory: true)
        print("Ready with root \(self.root)")
    }
    
    func load<T>(pick: Bool) throws -> T
    where T : Codable
    {
        if pick {
            let picker = FileReadPicker(def: self.lastPath)
            guard picker.runSync() else {
                throw FileError.CannotPickLoadFile
            }
            self.lastPath=picker.path
        }
        
        let d = try Data(contentsOf: URL(fileURLWithPath: self.lastPath))
        let decoder=JSONDecoder()
        return try decoder.decode(T.self, from: d)
    }
    
    func save<T>(_ data : T,pick: Bool,compact: Bool=true) throws
    where T : Codable
    {
        if pick || !self.isLastPathSet {
            let picker = FilePicker(def: self.lastPath)
            guard picker.runSync() else {
                throw FileError.CannotPickSaveFile
            }
            self.lastPath=picker.path
        }
        
        let encoder=JSONEncoder()
        if !compact { encoder.outputFormatting = .prettyPrinted }
        let d = try encoder.encode(data)
        try d.write(to: URL(fileURLWithPath: self.lastPath))
    }
    
}
