//
//  UserDefaults.swift
//  lace
//
//  Created by Julian Porter on 13/04/2022.
//

import Foundation
import AppKit


extension URL {
    init?(resource r: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: r, withExtension: ext) else { return nil }
        self=url
    }
}


class Defaults {
    let appName : String
    static let defPList = "defaults"
    
    static var the : Defaults?
    
    fileprivate init() {
        self.appName = Bundle.main.bundleIdentifier ?? ""
    }
    
    fileprivate func loadDefaults() -> [String:Any]? {
        guard let url = Bundle.main.url(forResource: Defaults.defPList, withExtension: "plist") else { return nil }
        if let d = NSDictionary(contentsOf: url) { return d as? [String:Any] }
        return nil
    }
    
    fileprivate func bootstrap() {
        let defs = UserDefaults.standard
        guard defs.persistentDomain(forName: self.appName)==nil else { return }

        syslog.info("About to bootstrap defaults")
        guard let defaults = loadDefaults() else { return }
        defs.setPersistentDomain(defaults, forName: self.appName)
        syslog.info("Defaults persistent domain set")
    }
    
    //fileprivate func reload() {
    //    UserDefaults.standard.dictionaryRepresentation()
    //}
    
    subscript<T>(_ key : String) -> T? {
        get { UserDefaults.standard.object(forKey: key) as? T }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
    
    
    
  
    public static func load() {
        the=Defaults()
        the?.bootstrap()
    }
    
    static func check() throws -> Defaults {
        guard the==nil else { return the! }
        load()
        guard let t=the else { throw DefaultError.CannotGetDefaults }
        return t
    }
    
    
    static func colour(forKey key : String) throws -> NSColor {
        let it = try check()
        
        guard let components : [CGFloat] = it[key] else { throw DefaultError.CannotGetKey(key) }
        guard components.count==4 else { throw DefaultError.BadColourFormat }
        return NSColor(components)
    }
    static func setColour(value: NSColor,forKey key: String) throws {
        let it=try check()
        guard let components = value.rgba, components.count==4 else { throw DefaultError.BadColourFormat }
        it[key]=components
                
    }
    
    static func font(forKey key : String) throws -> NSFont {
        let it = try check()
        guard let info : [String:Any] = it[key] else { throw DefaultError.CannotGetKey(key) }
        guard let f = NSFont(components: info) else { throw DefaultError.BadFontFormat }
        return f
    }
    
    static func setFont(value: NSFont,forKey key: String) throws {
        let it=try check()
        it[key]=value.components
    }
    
    static func string(forKey key : String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }
    static func setString(forKey key : String,value: String)  {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    static func double(forKey key : String) -> Double? {
        UserDefaults.standard.double(forKey: key)
    }
    static func setDouble(forKey key : String,value: Double)  {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    static func get<T>(forKey key : String) ->T? {
        UserDefaults.standard.object(forKey: key) as? T
    }
    static func set<T>(forKey key: String,value: T) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    
    
    
    
    
}
