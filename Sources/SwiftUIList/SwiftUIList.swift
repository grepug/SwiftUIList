import SwiftUI
import AppKit
import Combine

public struct SwiftUIList<Item: DataElement>: NSViewControllerRepresentable {
    public typealias NSViewControllerType = ListViewController<Item>
    public typealias Data = [Item]
    
    @Binding var data: [Item]
    var childrenKeyPath: ChildrenKeyPath<Item>?
    @Binding var selection: Set<Data.Element>
    var contextMenu: ContextMenu<Item>?
    var columns: [ListItemColumn] = [.init(title: "")]
    var content: ListItemContentType<Item>
    var onDoubleClicked: ((Int, Int, NSView) -> Void)?
    var hidingHeader = false
    var usingAlternatingRowBackgroundColors = false
    var drawingRowSeperators = false
    var allowingMultipleSelection = false
    var itemChanged: ItemChange<Item>?
    var operationSubject: OperationSubject<Item>?
    
    public init(_ data: Binding<[Item]>,
                selection: Binding<Item?>,
                children childrenKeyPath: ChildrenKeyPath<Item>? = nil,
                operationSubject: OperationSubject<Item>? = nil,
                content: @escaping ListItemContentType<Item>) {
        self._selection = .init {
            if let sel = selection.wrappedValue {
                return Set([sel])
            }

            return Set()
        } set: { newValue in
            selection.wrappedValue = newValue.first
        }

        self.content = content
        self._data = data
        self.operationSubject = operationSubject
        self.childrenKeyPath = childrenKeyPath
    }
    
    public init(_ data: Binding<Data>,
                selection: Binding<Set<Data.Element>>,
                children childrenKeyPath: ChildrenKeyPath<Item>? = nil,
                operationSubject: OperationSubject<Item>? = nil,
                content: @escaping ListItemContentType<Item>) {
        self._data = data
        self._selection = selection
        self.content = content
        self.allowingMultipleSelection = true
        self.operationSubject = operationSubject
        self.childrenKeyPath = childrenKeyPath
    }
    
    public func makeNSViewController(context: Context) -> NSViewControllerType {
        let vc = NSViewControllerType(data: data,
                                      childrenKeyPath: childrenKeyPath,
                                      operationSubject: operationSubject,
                                      contextMenu: contextMenu,
                                      content: content,
                                      selectionChanged: { selection = $0 },
                                      items: { data })
        
        return vc
    }
    
    public func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        nsViewController.setupColumns(columns)
        if childrenKeyPath == nil {
            nsViewController.updateData(newItems: data)
        } else {
            nsViewController.dataSource.getItems = { data }
        }
        nsViewController.changeSelectedItem(to: selection)
        nsViewController.tableView.onDoubleClicked = onDoubleClicked
        nsViewController.tableView.usesAlternatingRowBackgroundColors = usingAlternatingRowBackgroundColors
        nsViewController.delegate.columns = columns
        nsViewController.delegate.itemChanged = itemChanged
//        nsViewController.operationHandler = operationHandler
        
        nsViewController.tableView.gridColor = .gridColor
        nsViewController.tableView.gridStyleMask = drawingRowSeperators ? .solidHorizontalGridLineMask : []
        nsViewController.tableView.allowsMultipleSelection = allowingMultipleSelection
        
        if hidingHeader {
            nsViewController.tableView.headerView = nil
        }
    }
}
