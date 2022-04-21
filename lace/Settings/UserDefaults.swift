//
//  UserDefaults.swift
//  lace
//
//  Created by Julian Porter on 13/04/2022.
//

import Foundation
import AppKit

enum DefaultError : Error {
    case CannotGetKey(String)
    case BadColourFormat
}


class Defaults {
    let appName : String
    static let defPList = "defaults"
    
    public init() {
        self.appName = Bundle.main.bundleIdentifier ?? ""
    }
    
    private func loadDefaults() -> [String:Any]? {
        guard let url = Bundle.main.url(forResource: Defaults.defPList, withExtension: "plist") else { return nil }
        if let d = NSDictionary(contentsOf: url) { return d as? [String:Any] }
        return nil
    }
    
    public func bootstrap() {
        let defs = UserDefaults.standard
        guard defs.persistentDomain(forName: self.appName)==nil else { return }

        print("Need to bootstrap defaults")
        guard let defaults = loadDefaults() else { return }
        defs.setPersistentDomain(defaults, forName: self.appName)
        print("Set persistent domain")
    }
    
    subscript<T>(_ key : String) -> T? {
        get { UserDefaults.standard.object(forKey: key) as? T }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    
    func string(forKey key : String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }
    func setString(forKey key : String,value: String)  {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    func double(forKey key : String) -> Double? {
        UserDefaults.standard.double(forKey: key)
    }
    func setDouble(forKey key : String,value: Double)  {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    func colour(forKey key : String) throws -> NSColor {
        guard let components : [CGFloat] = self[key] else { throw DefaultError.CannotGetKey(key) }
        guard components.count==4 else { throw DefaultError.BadColourFormat }
        return NSColor(components)
    }
    func setColour(value: NSColor,forKey key: String) throws {
        guard let components = value.rgba, components.count==4 else { throw DefaultError.BadColourFormat }
        self[key]=components
                
    }
  
    public static func load() {
        let u=Defaults()
        u.bootstrap()
    }
    
    
    
}
