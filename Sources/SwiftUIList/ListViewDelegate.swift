//
//  ListViewDelegate.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import AppKit
import SwiftUI

class ListViewDelegate<Data: Sequence>: NSObject, NSTableViewDelegate where Data.Element: Identifiable {
    var items: [ListItem<Data>]
    let content: ListItemContentType<Data>
    let selectionChanged: (Data.Element?) -> Void
    var selectedItem: ListItem<Data>?
    
    init(items: [ListItem<Data>],
         content: @escaping ListItemContentType<Data>,
         selectionChanged: @escaping (Data.Element?) -> Void) {
        self.items = items
        self.content = content
        self.selectionChanged = selectionChanged
        
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
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        let tableView = notification.object as! TableView<Data>
        let selectedRow = tableView.selectedRow
        
        if selectedRow != -1 {
            let newSelection = item(at: selectedRow)
            
            if selectedItem?.id != newSelection.id {
                selectedItem = newSelection
                selectionChanged(selectedItem?.value)
            }
        }
    }
    
    private func item(at index: Int) -> ListItem<Data> {
        items[index]
    }
    
    func selectRow(
        for item: ListItem<Data>?,
        in tableView: TableView<Data>
    ) {
        if let item = item,
           let index = items.firstIndex(of: item) {
            tableView.selectRowIndexes(IndexSet([index]), byExtendingSelection: false)
        } else {
            tableView.deselectAll(nil)
        }
    }

    func changeSelectedItem(
        to item: ListItem<Data>?,
        in tableView: TableView<Data>
    ) {
        guard selectedItem?.id != item?.id else { return }
        selectedItem = item
        selectRow(for: selectedItem, in: tableView)
    }
}
