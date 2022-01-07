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
    typealias Data = [Item]
    
    let tableView: TableView<Item>
    let dataSource: OutlineViewDataSource<Item>
    let delegate: OutlineViewDelegate<Item>
    weak var operationSubject: OperationSubject<Item>?
    var operationHandler: ((ListOperation<Item>, NSOutlineView) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(data: Data,
         operationSubject: OperationSubject<Item>?,
         contextMenu: ContextMenu<Item>?,
         content: @escaping ListItemContentType<Item>,
         selectionChanged: @escaping SelectionChanged<Item>,
         items: @escaping () -> Data) {
        
        tableView = TableView(items: data, contextMenu: contextMenu)
        dataSource = .init(items: items)
        delegate = .init(content: content,
                         selectionChanged: selectionChanged)
        self.operationSubject = operationSubject
        
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
        
        operationSubject?
            .sink { [weak self] operation in
                guard let self = self else { return }
                
                self.operationHandler?(operation, self.tableView)
        }
        .store(in: &cancellables)
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
//    func updateData(newValue: Data) {
//        let newState = newValue
//
//        tableView.beginUpdates()
//
//        let oldState = dataSource.items
//        delegate.items = newState
//        
//        updater.performUpdates(
//            tableView: tableView,
//            oldState: oldState,
//            newState: newState,
//            parent: nil)
//
//        tableView.endUpdates()
//    }
    
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
