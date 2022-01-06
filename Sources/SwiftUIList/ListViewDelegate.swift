//
//  ListViewDelegate.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import AppKit
import SwiftUI

class ListViewDelegate<Data: Sequence>: NSObject, NSTableViewDelegate where Data.Element: DataElement {
    var items: [ListItem<Data>]
    let content: ListItemContentType<Data>
    let selectionChanged: SelectionChanged<Data>
    var selectedItems: Set<ListItem<Data>>
    
    var selectedItemIndexSet: IndexSet {
        selectedItems.reduce(into: IndexSet()) {
            if let index = self.items.firstIndex(of: $1) {
                $0.insert(index)
            }
        }
    }
    
    init(items: [ListItem<Data>],
         content: @escaping ListItemContentType<Data>,
         selectionChanged: @escaping SelectionChanged<Data>) {
        self.items = items
        self.content = content
        self.selectionChanged = selectionChanged
        self.selectedItems = []
        
        super.init()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let tableView = tableView as! TableView<Data>
        let column = tableView.tableColumns.firstIndex(of: tableColumn!)!
        let binding = Binding<Data.Element> {
            self.item(at: row).value
        } set: { newValue in
            self.items[row].value = newValue
        }
        
        return content(row, column, binding)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        22
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        rowView.drawSeparator(in: .zero)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object as! TableView<Data>
        let selectedRows = tableView.selectedRowIndexes
        
        if !selectedRows.isEmpty {
            if selectedItemIndexSet != selectedRows {
                let selection = Set(selectedRows.map { self.item(at: $0).value })
                
                selectionChanged(selection)
            }
        }
    }
    
    private func item(at index: Int) -> ListItem<Data> {
        items[index]
    }
    
    func selectRow(
        for items: Set<ListItem<Data>>,
        in tableView: TableView<Data>
    ) {
        if selectedItemIndexSet.isEmpty {
            tableView.deselectAll(nil)
        } else {
            tableView.selectRowIndexes(selectedItemIndexSet, byExtendingSelection: false)
        }
    }

    func changeSelectedItem(
        to items: Set<ListItem<Data>>,
        in tableView: TableView<Data>
    ) {
        let selectedIds = Set(selectedItems.map(\.id))
        let itemIds = Set(items.map(\.id))
        
        guard selectedIds != itemIds else { return }
        
        selectedItems = items
        selectRow(for: items, in: tableView)
    }
}
