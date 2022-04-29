//
//  FilePicker.swift
//  lace
//
//  Created by Julian Porter on 14/04/2022.
//

import AppKit
import UniformTypeIdentifiers

class FilePicker {
    typealias Handler = (Bool,String) -> ()
    var savePanel : NSSavePanel
    var path : String
    var dir : String?
    
    init(def : String?, types : [String] = ["json"]) {
        let ftypes = types.compactMap { UTType(filenameExtension: $0) }
        path = def ?? "./lace.json"
        savePanel=NSSavePanel.init()
        savePanel.showsTagField=false
        savePanel.canCreateDirectories=true
        savePanel.canSelectHiddenExtension=false
        savePanel.showsHiddenFiles=false
        savePanel.isExtensionHidden=false
        savePanel.allowedContentTypes=ftypes
        savePanel.allowsOtherFileTypes=false
        savePanel.treatsFilePackagesAsDirectories=false
        savePanel.nameFieldStringValue=self.path
    }
    
    @discardableResult func handler(_ response : NSApplication.ModalResponse) -> Bool {
        switch response {
        case .OK:
            guard let url=self.savePanel.url else { return false }
            self.path = url.path
            self.dir = self.savePanel.directoryURL?.path
            return true
        case .cancel:
            return false
        default:
            return false
        }
    }
    
    
    
    @discardableResult func runSync() -> Bool {
        let result = savePanel.runModal()
        return handler(result)
    }
    
}

class FileReadPicker {
    typealias Handler = (Bool,String) -> ()
    var loadPanel : NSOpenPanel
    var path : String
    
    init(def : String?, types : [String] = ["json"]) {
        let ftypes = types.compactMap { UTType(filenameExtension: $0) }
        path = def ?? "./lace.json"
        loadPanel=NSOpenPanel.init()
        loadPanel.canChooseFiles=true
        loadPanel.canChooseDirectories=false
        loadPanel.resolvesAliases=true
        loadPanel.allowsMultipleSelection=false
        loadPanel.canDownloadUbiquitousContents=true
        loadPanel.showsTagField=false
        loadPanel.canSelectHiddenExtension=false
        loadPanel.showsHiddenFiles=false
        loadPanel.isExtensionHidden=false
        loadPanel.allowedContentTypes=ftypes
        loadPanel.allowsOtherFileTypes=false
        loadPanel.treatsFilePackagesAsDirectories=false
        loadPanel.nameFieldStringValue=self.path
    }
    
    @discardableResult func handler(_ response : NSApplication.ModalResponse) -> Bool {
        switch response {
        case .OK:
            guard let url=self.loadPanel.urls.first else { return false }
            self.path = url.path
            return true
        case .cancel:
            return false
        default:
            return false
        }
    }
    
    @discardableResult func runSync() -> Bool {
        let result = loadPanel.runModal()
        return handler(result)
    }
    
}


