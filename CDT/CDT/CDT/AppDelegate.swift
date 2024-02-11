//
//  AppDelegate.swift
//  CDT
//
//  Created by Julian Porter on 04/02/2024.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    public private(set) var handler : DataHandler?
    public static let ModelName : String = "DataModel"

    func applicationDidFinishLaunching(_ aNotification: Notification) {
       
        Task {
            let bootstrap = CoreDataBootStrap(model: AppDelegate.ModelName)
            let handler : DataHandler? = await bootstrap.connect()
            self.runTests(handler: handler)
            self.handler=handler
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


    func runTests(handler: DataHandler?) {
        guard let handler=handler else { return }
        
        do {
            
        }
        catch(let e) { print("Error \(e)") }
        
    }
}

