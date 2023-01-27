//
//  AppDelegate.swift
//  lace
//
//  Created by Julian Porter on 01/04/2022.
//

import Cocoa
import UniformTypeIdentifiers

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    @IBOutlet weak var controller: Controller!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        Defaults.load()
        FilePaths.load()
        
        // START AUTOSAVE:
        //
        // autosave calles controller.doBackup()
        
        //NSApplication.shared.activate(ignoringOtherApps: true)
        // NSOpenPanel
        //self.doPrinting()
        //printActions()
    }
    
    /*
    func doPrinting() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType.jpeg] // "com.adobe.pdf"
        openPanel.allowsMultipleSelection = true
        if (openPanel.runModal() != NSApplication.ModalResponse.OK) { return }
        
        let filePaths: [String] = openPanel.urls.compactMap({ $0.path })
        filePaths.forEach { self.loadAndPrint(path: $0) }
    }
    func loadAndPrint(path: String) {
        let pageRanges : [[UInt32]] = [[1,1]]
        
        let img = NSImage(contentsOfFile: path)!
        let nv = NSImageView(image: img)
        nv.frame=NSRect(origin: CGPoint(), size: img.size)
        
        var printInfo = NSPrintInfo()
        
        // --- Print Panel ---
        let printPanel = NSPrintPanel()
        
        printPanel.options = [
            NSPrintPanel.Options.showsCopies,
            NSPrintPanel.Options.showsPageSetupAccessory
        ]
        
        if printPanel.runModal(with: printInfo) != NSApplication.ModalResponse.OK.rawValue {
            return
        }
        printInfo = printPanel.printInfo
        let sizeInPoints = printInfo.paperSize
        print("Size in points is \(sizeInPoints)")
        
        
        let printSettingCPtr = PMPrintSettings(printInfo.pmPrintSettings())
        let sess=PMPrintSession(printInfo.pmPrintSession())
        var prin : PMPrinter?
        PMSessionGetCurrentPrinter(sess, &prin)
        var r = PMResolution()
        PMPrinterGetOutputResolution(prin!, printSettingCPtr, &r)
        print("Resolution is \(r)")
        
        var printedPageRanges = Array<Array<UInt32>>()
        
        for pageRange in pageRanges {
            guard let first = pageRange.first else { continue }
            guard let last = pageRange.last else { continue }
            
            if PMSetPageRange(printSettingCPtr, first, last) == OSStatus(kPMValueOutOfRange) { continue }
            
            PMSetFirstPage(printSettingCPtr, first, false)
            PMSetLastPage(printSettingCPtr, last, false)
            printInfo.updateFromPMPrintSettings()
            /*
            let nspo = NSPrintOperation(view: nv, printInfo: printInfo)
            nspo.jobTitle = path
            nspo.showsPrintPanel = false
            if nspo.run() {
                printedPageRanges.append(pageRange)
            }
             */
        }
        
        print("\(path): printed pages in ranges \(printedPageRanges)")
    }
    */
     
     func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
         
         // STOP AUTOSAVE
         controller.doBackup()
         FilePaths.shutdown()
         Defaults.shutdown()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    


}

