//
//  Launchable.swift
//  lace
//
//  Created by Julian Porter on 16/04/2022.
//

import Foundation
import AppKit

protocol LaunchableItem
{
    static var nibname : NSNib.Name {get}
    static var lock : NSLock {get}
}

extension LaunchableItem {
    
    public static func instance() -> Self? {
        var view : Self? = nil
        if(lock.try()) {
            let nib=NSNib(nibNamed: nibname, bundle: nil)
            var array : NSArray?
            if nib != nil {
                nib!.instantiate(withOwner: nil, topLevelObjects: &array)
                let p=array?.filter { $0 is Self } ?? []
                if p.count > 0 { view=(p[0] as! Self) }
            }
            lock.unlock()
        }
        return view
    }
}

protocol Openable {
    func makeKeyAndOrderFront(_: Any?)
    func performClose(_: Any?)
    var  isReleasedWhenClosed : Bool { get }
}

protocol LaunchableSingletonItem : LaunchableItem, Openable {
    static var item : Self? { get set }
    func initialise(args : [String:Any])
}

extension LaunchableSingletonItem {
    
    public static func launch(args : [String:Any] = [:]) -> Self? {
        if item==nil {
            item=instance()
            item?.initialise(args: args)
        }
        item?.makeKeyAndOrderFront(nil)
        return item
    }
    
    @discardableResult static func close() -> Self? {
        guard let p=item else { return nil }
        let release = p.isReleasedWhenClosed
        p.performClose(nil)
        if release { item = nil }
        return item
    }
    
    static func reset() {
        close()
        item=nil
    }
}

protocol LaunchableKeyedItem : LaunchableItem {
    var title : String { get set}
    func performClose(_ sender : Any?)
    static var items : [UUID : LaunchableKeyedItem] {get set}
    func unlink()
}

extension LaunchableKeyedItem {
    
    public static func instance(uid : UUID = UUID(),title : String? = nil) -> Self? {
        var panel = items[uid] as! Self?
        if panel==nil {
            panel=instance()
            if title != nil { panel?.title=title! }
            items[uid] = panel
        }
        return panel
    }
    
    public static func close(uid : UUID) -> Self? {
        guard let item=items[uid] else { return nil }
        item.performClose(nil)
        return items[uid] as! Self?
    }
    
    public static func reset() {
        items.removeAll()
    }
}

