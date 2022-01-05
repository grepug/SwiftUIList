//
//  ListViewController.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import AppKit
import SwiftUI

public class ListViewController<Data: Sequence>: NSViewController where Data.Element: Identifiable {
    let tableView: TableView<Data>
    let dataSource: ListViewDataSource<Data>
    let delegate: ListViewDelegate<Data>
    let updater = ListViewUpdater<Data>()
    
    init(data: Data,
         content: @escaping (Data.Element) -> NSView,
         contextMenus: ((Data.Element, Int, Int) -> [ListItemContextMenu])?,
         selectionChanged: @escaping (Data.Element?) -> Void) {
        let items: [ListItem<Data>] = data.map { .init($0) }
        tableView = TableView(items: items, contextMenus: contextMenus)
        
        dataSource = .init()
        delegate = .init(items: items,
                         content: content,
                         selectionChanged: selectionChanged)
        
        super.init(nibName: nil, bundle: nil)
        
        let scrollView = view as! NSScrollView
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.rowSizeStyle = .default
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = NSScrollView(frame: .zero)
    }
}

extension ListViewController {
    func updateData(newValue: Data) {
        let newState: [ListItem<Data>] = newValue.map { .init($0) }

//        tableView.beginUpdates()

        let oldState = dataSource.items
        dataSource.items = newState
        delegate.items = newState
        
        print("count2", newState.count, oldState.count)
        
        updater.performUpdates(
            tableView: tableView,
            oldState: oldState,
            newState: newState)

//        tableView.endUpdates()
    }
    
    func changeSelectedItem(to item: Data.Element?) {
        delegate.changeSelectedItem(
            to: item.map { ListItem($0) },
            in: tableView)
    }
}
