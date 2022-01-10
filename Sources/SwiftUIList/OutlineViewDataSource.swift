//
//  File.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit

class OutlineViewDataSource<Item: DataElement>: NSObject, NSOutlineViewDataSource {
    typealias Data = [Item]
    
    var items: (() -> Data)
    var childrenKeyPath: ChildrenKeyPath<Item>?
    
    init(items: @escaping () -> Data,
         childrenKeyPath: ChildrenKeyPath<Item>?) {
        self.items = items
        self.childrenKeyPath = childrenKeyPath
    }
    
    private func typedItem(_ item: Any) -> Item {
        item as! Item
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        let items = items()
        
        if let item = item.map(typedItem), let keyPath = childrenKeyPath {
            return item[keyPath: keyPath]?.count ?? 0
        }
        
        return items.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let childrenKeyPath = childrenKeyPath {
            return typedItem(item)[keyPath: childrenKeyPath] != nil
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        let items = items()
        
        if let item = item.map(typedItem), let keyPath = childrenKeyPath {
            return item[keyPath: keyPath]![index]
        }
        
        return items[index]
    }
}


