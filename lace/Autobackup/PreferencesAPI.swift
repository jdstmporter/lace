//
//  PreferencesAPI.swift
//  lace
//
//  Created by Julian Porter on 06/02/2023.
//

import Foundation

class Preferences {
    static let ID : CFString = kCFPreferencesCurrentApplication
    let key : CFString
    
    init() {
        let prefix = Bundle.main.bundleIdentifier ?? ""
        self.key = "\(prefix).backup" as CFString
    }
    
    enum PreferencesError : Error {
        case SynchronisationFailed
        case BadType
    }
    
    
    fileprivate func _sync() throws {
        guard CFPreferencesAppSynchronize(Preferences.ID) else { throw PreferencesError.SynchronisationFailed }
    }
    
    func save(_ p : Pricking) throws {
        let v = p.enc() as? CFPropertyList
        CFPreferencesSetAppValue(key, v,Preferences.ID)
        try _sync()
    }
    func load() -> Pricking? {
        guard let v = CFPreferencesCopyAppValue(key, Preferences.ID) else { return nil }
        return Pricking.dec(v)
    }
    func new() throws {
        CFPreferencesSetAppValue(key, nil,Preferences.ID)
        try _sync()
    }
}

