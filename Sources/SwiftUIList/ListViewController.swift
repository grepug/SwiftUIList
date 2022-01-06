//
//  ListViewController.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import AppKit
import SwiftUI

public class ListViewController<Data: Sequence>: NSViewController where Data.Element: DataElement {
    let tableView: TableView<Data>
    let dataSource: OutlineViewDataSource<Data>
    let delegate: OutlineViewDelegate<Data>
    let updater = ListViewUpdater<Data>()
    
    init(data: Data,
         childrenKeyPath: ChildrenKeyPath<Data>?,
         content: @escaping ListItemContentType<Data>,
         contextMenu: ContextMenu<Data>?,
         selectionChanged: @escaping SelectionChanged<Data>,
         itemsChanged: @escaping ItemsChanged<Data>) {
        let items: [ListItem<Data>] = data.map { .init($0, children: childrenKeyPath) }
        
        tableView = TableView(items: items, contextMenu: contextMenu)
        dataSource = .init()
        delegate = .init(items: items,
                         content: content,
                         selectionChanged: selectionChanged,
                         itemsChanged: itemsChanged)
        
        super.init(nibName: nil, bundle: nil)
        
        let scrollView = view as! NSScrollView
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.rowSizeStyle = .default
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.autoresizesOutlineColumn = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = NSScrollView(frame: .zero)
    }
    
    public override func viewWillAppear() {
        // Size the column to take the full width. This combined with
        // the uniform column autoresizing style allows the column to
        // adjust its width with a change in width of the outline view.
        tableView.sizeLastColumnToFit()
        super.viewWillAppear()
    }
}

extension ListViewController {
    func updateData(newValue: Data, children: ChildrenKeyPath<Data>?) {
        let newState: [ListItem<Data>] = newValue.map { .init($0, children: children) }

        tableView.beginUpdates()

        let oldState = dataSource.items
        dataSource.items = newState
        delegate.items = newState
        
        updater.performUpdates(
            tableView: tableView,
            oldState: oldState,
            newState: newState,
            parent: nil)

        tableView.endUpdates()
    }
    
    func changeSelectedItem(to item: Set<Data.Element>) {
        delegate.changeSelectedItem(
            to: Set(item.map { ListItem($0) }),
            in: tableView)
    }
    
    func setupColumns(_ columns: [ListItemColumn]) {
        guard tableView.tableColumns.isEmpty else { return }
        
        for item in columns {
            let column = NSTableColumn(identifier: .init(rawValue: item.id))
            column.title = item.title
            if let width = item.width {
                column.width = width
            }
            if let fixedWidth = item.fixedWidth {
                column.minWidth = fixedWidth
                column.maxWidth = fixedWidth
            }
            if let maxWidth = item.maxWidth {
                column.maxWidth = maxWidth
            }
            if let minWidth = item.minWidth {
                column.minWidth = minWidth
            }
            
            tableView.addTableColumn(column)
        }
    }
}
