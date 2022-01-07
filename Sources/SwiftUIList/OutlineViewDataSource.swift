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
    
    init(items: @escaping () -> Data) {
        self.items = items
    }
    
    private func typedItem(_ item: Any) -> Item {
        item as! Item
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        let items = items()
        
        if let item = item.map(typedItem) {
            return item.children?.count ?? 0
        }
        
        return items.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        typedItem(item).children != nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        let items = items()
        
        if let item = item.map(typedItem) {
            print(item)
            return item.children![index]
        }
        
        return items[index]
    }
}


