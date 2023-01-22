//
//  UserDefaults.swift
//  lace
//
//  Created by Julian Porter on 13/04/2022.
//

import Foundation
import AppKit




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
    
    fileprivate func commit() {
    }
    
    subscript<T>(_ key : String) -> T? where T : EncDec {
        get {
            guard let x = UserDefaults.standard.object(forKey: key) else { return nil }
            return dec(x)
        }
        set {
            if let nv=newValue, let e = enc(nv) {
                UserDefaults.standard.set(e, forKey: key)
            }
        }
    }
    
    public static func load() {
        the=Defaults()
        the?.bootstrap()
    }
    public static func shutdown() {
        the?.commit()
    }
    
    static func check() throws -> Defaults {
        guard the==nil else { return the! }
        load()
        guard let t=the else { throw DefaultError.CannotGetDefaults }
        return t
    }
    
    static func read<T>(_ key: String) throws -> T where T : EncDec {
        let it = try check()
        guard let c : T = it[key] else { throw DefaultError.CannotDecodeKey(key) }
        return c
    }
    static func write<T>(_ key: String,_ value : T) throws where T : EncDec {
        let it = try check()
        it[key]=value
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
    
    static func GetPart<T>(kind : DefaultKind,part : any DefaultPart) -> T? where T : EncDec {
        syslog.announce("GET kind=\(kind) part=\(part)")
        return try? read(Key(kind,part))
    }
    static func SetPart<T>(kind : DefaultKind,part : any DefaultPart,value : T) where T : EncDec {
        syslog.announce("SET kind=\(kind) part=\(part)")
        try? write(Key(kind,part), value)
    }
    static func RemovePart(kind : DefaultKind,part : any DefaultPart) {
        remove(forKey: Key(kind,part))
    }
    
 
}





