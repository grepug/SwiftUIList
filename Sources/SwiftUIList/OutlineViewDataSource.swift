//
//  File.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit

class OutlineViewDataSource<Data: Sequence>: NSObject, NSOutlineViewDataSource where Data.Element: DataElement {
    var items: [ListItem<Data>] = []
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        print("count", items.count)
        return items.count
    }
    
    private func typedItem(_ item: Any) -> ListItem<Data> {
        item as! ListItem<Data>
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item.map(typedItem) {
            return item.children?.count ?? 0
        }
        
        return items.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        typedItem(item).children != nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item.map(typedItem) {
            return item.children![index]
        }
        
        return items[index]
    }
}


