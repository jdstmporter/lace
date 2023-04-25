//
//  popoverProtool.swift
//  lace
//
//  Created by Julian Porter on 22/01/2023.
//

import AppKit

typealias ModalHandler = (NSApplication.ModalResponse) -> Void

protocol ModalCallback {
    associatedtype Result
    typealias Callback = (Result?) -> Void
    
    var outcome : Result { get }
    func handler( _ : @escaping Callback) -> ModalHandler
    
}

protocol ModalTarget {
    associatedtype ModalType where ModalType : ModalCallback
    
    func callback(_ : ModalType.Result?)
    func handle(_ : ModalType)
}

extension ModalTarget {
    
    func handle(_ cb: ModalType) -> ModalHandler {
        cb.handler ({ x in self.callback(x) })
    }
    
}

extension ModalCallback {
    
    public func handler(_ callback : @escaping Callback) -> ModalHandler {
        { _ in callback(self.outcome) }
    }
}
