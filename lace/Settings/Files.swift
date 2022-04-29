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

extension URL {
    static var userHome : URL { URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true) }
}

class LoadSaveFiles {
    
    let root : URL
    
    var lastPath : String {
        get {
            let s : String? = Defaults.string(forKey:"LastPath")
            return s ?? self.root.path
        }
        set { Defaults.setString(forKey:"LastPath",value: newValue) }
    }
    var isLastPathSet : Bool {
        let s : String? = Defaults.string(forKey:"LastPath")
        return s != nil
    }
    
    init()  throws {
       
        var path : String? = Defaults.string(forKey: "DataDirectory")
        print("Loaded path: \(path ?? "nil")")
        if path == nil {    /* need to set path*/
            guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            else { throw FileError.CannotFindBundleIdentifier }
            var userHome = URL.userHome
            userHome.appendPathComponent(appName)
            path = userHome.path
            print("Setting path to \(path!)")
            Defaults.setString(forKey: "DataDirectory", value:path!)
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
    
    static func RootPath() throws -> URL {
        try LoadSaveFiles().root
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
