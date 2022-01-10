//
//  OutlineViewDelegate.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit
import SwiftUI

class OutlineViewDelegate<Item: DataElement>: NSObject, NSOutlineViewDelegate {
    typealias Data = [Item]
    
    let content: ListItemContentType<Item>
    let selectionChanged: SelectionChanged<Item>
    let childrenKeyPath: ChildrenKeyPath<Item>?
    var columns: [ListItemColumn]?
    var itemChanged: ItemChange<Item>?
    
    private var selectedItems: Set<Item>
    
    init(content: @escaping ListItemContentType<Item>,
         selectionChanged: @escaping SelectionChanged<Item>,
         childrenKeyPath: ChildrenKeyPath<Item>? = nil) {
        self.content = content
        self.selectionChanged = selectionChanged
        self.selectedItems = []
        self.childrenKeyPath = childrenKeyPath
        
        super.init()
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let item = typedItem(item: item)
        let row = outlineView.row(forItem: item)
        let column = outlineView.tableColumns.firstIndex(of: tableColumn!)!
        let shouldReload = columns?[column].shouldReloadOnUpdate ?? false
        
        let binding = Binding<Item> {
            item
        } set: { [weak self] newValue in
            self?.itemChanged?(row, column, newValue)
            
            if shouldReload {
                outlineView.reloadItem(item, reloadChildren: false)
                
                let isSelected = outlineView.isRowSelected(row)
                if isSelected {
                    outlineView.deselectRow(row)
                    DispatchQueue.main.async {
                        outlineView.selectRowIndexes([row], byExtendingSelection: true)
                    }
                }
            }
        }
        
        return content(row, column, binding)
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        24
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        let outlineView = notification.object as! NSOutlineView
        if outlineView.selectedRow == -1 {
            selectRow(for: selectedItems, in: outlineView)
        }
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        let outlineView = notification.object as! NSOutlineView
        let selectedRows = outlineView.selectedRowIndexes
        let selectedItemIndexSet = selectedItemIndexSet(outlineView: outlineView)
        
        if !selectedRows.isEmpty {
            if selectedItemIndexSet != selectedRows {
                let selection = Set(selectedRows
                                        .compactMap { outlineView.item(atRow: $0) }
                                        .map { self.typedItem(item: $0) })
                
                DispatchQueue.main.async { [weak self] in
                    self?.selectionChanged(selection)
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.selectionChanged([])
            }
        }
    }
    
    func outlineViewItemWillCollapse(_ notification: Notification) {
        guard let item = notification.userInfo?.first?.value as? Item else {
            return
        }
        let outlineView = notification.object as! NSOutlineView
        let isChildrenSelected = isChildrenSelected(outlineView: outlineView, item: item)
        
        if isChildrenSelected {
            let row = outlineView.row(forItem: item)
            outlineView.selectRowIndexes([row], byExtendingSelection: false)
        }
    }
}

extension OutlineViewDelegate {
    func selectRow(
        for items: Set<Item>,
        in outlineView: NSOutlineView
    ) {
        let selectedItemIndexSet = selectedItemIndexSet(outlineView: outlineView)
        
        if selectedItemIndexSet.isEmpty {
            outlineView.deselectAll(nil)
        } else {
            outlineView.selectRowIndexes(selectedItemIndexSet, byExtendingSelection: false)
        }
    }

    func changeSelectedItem(
        to items: Set<Item>,
        in tableView: NSOutlineView
    ) {
        let selectedIds = Set(selectedItems.map(\.id))
        let itemIds = Set(items.map(\.id))
        
        guard selectedIds != itemIds else { return }
        
        selectedItems = items
        selectRow(for: items, in: tableView)
    }
}

private extension OutlineViewDelegate {
    func typedItem(item: Any) -> Item {
        item as! Item
    }
    
    func selectedItemIndexSet(outlineView: NSOutlineView) -> IndexSet {
        selectedItems.reduce(into: IndexSet()) {
            let index = outlineView.row(forItem: $1)
            if index > -1 {
                $0.insert(index)
            }
        }
    }
    
    func isChildrenSelected(outlineView: NSOutlineView, item: Item) -> Bool {
        let selectedRows = outlineView.selectedRowIndexes
        
        if let keyPath = childrenKeyPath, let children = item[keyPath: keyPath] {
            for item in children {
                let row = outlineView.row(forItem: item)
                
                if selectedRows.contains(row) {
                    return true
                }
                
                return isChildrenSelected(outlineView: outlineView, item: item)
            }
        }
        
        return false
    }
    
    func updateNewItem(_ newItem: Data.Element, items: Data) -> Data {
        var items = items
        
        for (i, item) in items.enumerated() {
            if item.id == newItem.id {
                items[i] = newItem
            }
            
            if let keyPath = childrenKeyPath, let children = item[keyPath: keyPath] {
                items[i][keyPath: keyPath] = updateNewItem(newItem, items: children)
            }
        }
        
        return items
    }
}
