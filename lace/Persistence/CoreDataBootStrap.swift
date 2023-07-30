//
//  CoreDataBootStrap.swift
//  lace
//
//  Created by Julian Porter on 17/04/2023.
//

import Foundation
import CoreData

struct TimedOutError: Error, Equatable {}

class CoreDataBootStrap {
    public typealias SuccessHandler = (CoreDataBootStrap) -> Void
    public typealias FailureHandler = (Error) -> Void
    
    static var common : CoreDataBootStrap?
    
    var persistentContainer : NSPersistentContainer
    var moc : NSManagedObjectContext { self.persistentContainer.viewContext }
    var success : SuccessHandler?
    var failure : FailureHandler?
    var timeout : TimeInterval
    
    init(model : String,success: SuccessHandler? = nil,failure: FailureHandler? = nil,timeout: TimeInterval = 1.0) {
        self.success=success
        self.failure=failure
        self.timeout=timeout
        
        self.persistentContainer = NSPersistentContainer(name: model)
    }
    
    func connectToTechnology() async throws {
        let _ : NSManagedObjectContext = try await withCheckedThrowingContinuation { continuation in
            self.persistentContainer.loadPersistentStores { description, error in
                if let error=error {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume(returning: self.persistentContainer.viewContext)
                }
            }
        }
    }
    
    func connectWithTimeout() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            let deadline = Date(timeIntervalSinceNow: self.timeout)
            
            group.addTask { try await self.connectToTechnology() }
            
            group.addTask {
                let interval = deadline.timeIntervalSinceNow
                if interval > 0 {
                    try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                }
                try Task.checkCancellation()
                throw TimedOutError()
            }
            try await group.next()
            group.cancelAll()
        }
    }
    
    func connect() async -> DataHandler? {
        do {
            try await self.connectWithTimeout()
            self.success?(self)
            return DataHandler(container: self.persistentContainer)
        }
        catch (let e) {
            self.failure?(e)
            return nil
        }
    }

    
    
    
}

