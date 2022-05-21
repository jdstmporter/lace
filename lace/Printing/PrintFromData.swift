//
//  PrintFromData.swift
//  lace
//
//  Created by Julian Porter on 21/05/2022.
//

import AppKit
import ApplicationServices
import UniformTypeIdentifiers

func loadAndPrint(data: Data) {
    let img = NSImage(data: data)!
    let nv = NSImageView(image: img)
    nv.frame=NSRect(origin: CGPoint(), size: img.size)
    
    var printInfo = NSPrintInfo()
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
    

        
        if PMSetPageRange(printSettingCPtr, 1,1) == OSStatus(kPMValueOutOfRange) { return }
        
        PMSetFirstPage(printSettingCPtr, 1, false)
        PMSetLastPage(printSettingCPtr, 1, false)
        printInfo.updateFromPMPrintSettings()
        
        let nspo = NSPrintOperation(view: nv, printInfo: printInfo)
        nspo.jobTitle = "Print"
        nspo.showsPrintPanel = false
        nspo.run()
        
    
}
