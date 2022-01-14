//
//  ListViewController.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import AppKit
import SwiftUI
import Combine

public class ListViewController<Item: DataElement>: NSViewController {
    let tableView: OutlineView<Item>
    let dataSource: OutlineViewDataSource<Item>
    let delegate: OutlineViewDelegate<Item>
    weak var operationSubject: OperationSubject<Item>?
    var childrenKeyPath: ChildrenKeyPath<Item>?
    var dataChanged: DataChange<Item>
    
    private var cancellables = Set<AnyCancellable>()
    
    init(data: [Item],
         childrenKeyPath: ChildrenKeyPath<Item>?,
         operationSubject: OperationSubject<Item>?,
         contextMenu: ContextMenu<Item>?,
         content: @escaping ListItemContentType<Item>,
         selectionChanged: @escaping SelectionChanged<Item>,
         dataChanged: @escaping DataChange<Item>) {
        tableView = OutlineView(items: data, contextMenu: contextMenu)
        dataSource = .init(childrenKeyPath: childrenKeyPath)
        delegate = .init(content: content,
                         selectionChanged: selectionChanged,
                         childrenKeyPath: childrenKeyPath)
        self.childrenKeyPath = childrenKeyPath
        self.operationSubject = operationSubject
        self.dataChanged = dataChanged
        
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
        setupSubscribers()
    }
    
    public override func viewWillAppear() {
        // Size the column to take the full width. This combined with
        // the uniform column autoresizing style allows the column to
        // adjust its width with a change in width of the outline view.
        tableView.sizeLastColumnToFit()
        super.viewWillAppear()
    }
    
    func setupSubscribers() {
        operationSubject?
            .sink { operation in
                self.operationHandler(operation: operation,
                                      outlineView: self.tableView)
            }
            .store(in: &cancellables)
    }
}

extension ListViewController {
    func updateData(newItems: [Item]) {
        let oldItems = dataSource.items
        
        guard childrenKeyPath == nil || oldItems.isEmpty else { return }
        
        dataSource.items = newItems
        
        let diff = newItems.difference(from: oldItems, by: { $0 == $1 })
        
        tableView.beginUpdates()
        
        for change in diff.steps {
            switch change {
            case .move(_, from: let fromIndex, to: let toIndex):
                tableView.moveItem(at: fromIndex, inParent: nil, to: toIndex, inParent: nil)
            case .insert(_, at: let index):
                tableView.insertItems(at: [index], inParent: nil, withAnimation: .effectFade)
            case .remove(_, at: let index):
                tableView.removeItems(at: [index], inParent: nil, withAnimation: .effectFade)
            }
        }

        tableView.endUpdates()
    }
    
    func changeSelectedItem(to item: Set<Item>) {
        delegate.changeSelectedItem(
            to: item,
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
