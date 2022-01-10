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
    
    let tableView: OutlineView<Item>
    let dataSource: OutlineViewDataSource<Item>
    let delegate: OutlineViewDelegate<Item>
    weak var operationSubject: OperationSubject<Item>?
    var operationHandler: ((ListOperation<Item>, OutlineView<Item>, OutlineViewDataSource<Item>) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(data: Data,
         childrenKeyPath: ChildrenKeyPath<Item>?,
         operationSubject: OperationSubject<Item>?,
         contextMenu: ContextMenu<Item>?,
         content: @escaping ListItemContentType<Item>,
         selectionChanged: @escaping SelectionChanged<Item>,
         items: @escaping () -> Data) {
        
        tableView = OutlineView(items: data, contextMenu: contextMenu)
        dataSource = .init(items: items, childrenKeyPath: childrenKeyPath)
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
            .sink { operation in
                self.operationHandler?(operation, self.tableView, self.dataSource)
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
    func updateData(newItems: [Item]) {
        let oldItems = dataSource.cachedItems
        dataSource.cachedItems = newItems
        
        let diff = newItems.difference(from: oldItems, by: { $0.id == $1.id }).inferringMoves()
        var movedIds = Set<Item.ID>()
        
        tableView.beginUpdates()
        
        for change in diff {
            switch change {
            case .insert(offset: let index, element: let item, associatedWith: let prevIndex):
                if let prevIndex = prevIndex {
                    tableView.moveItem(at: prevIndex, inParent: nil, to: index, inParent: nil)
                    movedIds.insert(item.id)
                } else {
                    tableView.insertItems(at: [index], inParent: nil, withAnimation: .effectFade)
                }
            case .remove(offset: let index, element: let item, _):
                if !movedIds.contains(item.id) {
                    tableView.removeItems(at: [index], inParent: nil, withAnimation: .effectFade)
                }
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
