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
        let item=items[uid]
        item?.performClose(nil)
        return items[uid] as! Self?
    }
    
    public static func reset() {
        items.removeAll()
    }
}

