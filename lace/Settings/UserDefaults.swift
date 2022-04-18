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
    
    public var colours : ViewPartColours {
        get {
            let v=ViewPartColours()
            ViewPart.allCases.forEach { p  in
                if let c : [CGFloat] = self["Colours-\(p)"] {
                    v[p]=NSColor(c)
                }
            }
            return v
        }
        set {
            ViewPart.allCases.forEach { p in
                let c=newValue[p].rgba
                self["Colours-\(p)"]=c
            }
        }
    }
    public static func load() {
        let u=Defaults()
        u.bootstrap()
    }
    
    
    
}
