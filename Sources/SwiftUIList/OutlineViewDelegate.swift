//
//  OutlineViewDelegate.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit
import SwiftUI

class OutlineViewDelegate<Data: Sequence>: NSObject, NSOutlineViewDelegate where Data.Element: DataElement {
    var items: [ListItem<Data>]
    let content: ListItemContentType<Data>
    let selectionChanged: SelectionChanged<Data>
    var itemsChanged: ItemsChanged<Data>?
    
    private var selectedItems: Set<ListItem<Data>>
    
    init(items: [ListItem<Data>],
         content: @escaping ListItemContentType<Data>,
         selectionChanged: @escaping SelectionChanged<Data>) {
        self.items = items
        self.content = content
        self.selectionChanged = selectionChanged
        self.selectedItems = []
        
        super.init()
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let item = typedItem(item: item)
        let row = outlineView.row(forItem: item)
        
        let column = outlineView.tableColumns.firstIndex(of: tableColumn!)!
        
        let binding = Binding<Data.Element> {
            item.value
        } set: { newValue in
            var items = self.items.map(\.value)
            
            for (i, item) in items.enumerated() {
                if item.id == newValue.id {
                    items[i] = newValue
                    break
                }
            }
            
            self.itemsChanged?(items as! Data)
        }
        
        return content(row, column, binding)
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        22
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
                                        .map { self.typedItem(item: $0).value })
                
                selectionChanged(selection)
            }
        }
    }
    
    func outlineViewItemWillCollapse(_ notification: Notification) {
        guard let item = notification.userInfo?.first?.value as? ListItem<Data> else {
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
        for items: Set<ListItem<Data>>,
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
        to items: Set<ListItem<Data>>,
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
    func typedItem(item: Any) -> ListItem<Data> {
        item as! ListItem<Data>
    }
    
    func selectedItemIndexSet(outlineView: NSOutlineView) -> IndexSet {
        selectedItems.reduce(into: IndexSet()) {
            let index = outlineView.row(forItem: $1)
            if index > -1 {
                $0.insert(index)
            }
        }
    }
    
    func isChildrenSelected(outlineView: NSOutlineView, item: ListItem<Data>) -> Bool {
        let selectedRows = outlineView.selectedRowIndexes
        
        if let children = item.children {
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
    
    func updateNewItem(id: Data.Element.ID, item: Data.Element) {
        
    }
}
