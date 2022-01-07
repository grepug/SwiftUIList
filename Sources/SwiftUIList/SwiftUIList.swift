import SwiftUI
import AppKit

public struct SwiftUIList<Item: DataElement>: NSViewControllerRepresentable {
    public typealias NSViewControllerType = ListViewController<Item>
    public typealias Data = [Item]
    
    @Binding var data: Data
    @Binding var selection: Set<Data.Element>
    var contextMenu: ContextMenu<Data>?
    var columns: [ListItemColumn] = [.init(title: "")]
    var content: ListItemContentType<Data>
    var onDoubleClicked: ((Int, Int, NSView) -> Void)?
    var hidingHeader = false
    var usingAlternatingRowBackgroundColors = false
    var drawingRowSeperators = false
    var allowingMultipleSelection = false
    
    public init(_ data: Data,
                selection: Binding<Data.Element?>,
                content: @escaping ListItemContentType<Data>) {
        self._selection = .init {
            if let sel = selection.wrappedValue {
                return Set([sel])
            }
            
            return Set()
        } set: { newValue in
            selection.wrappedValue = newValue.first
        }
        
        self.content = content
        self._data = .constant(data)
    }
    
    public init(_ data: Binding<Data>,
                selection: Binding<Data.Element?>,
                content: @escaping ListItemContentType<Data>) {
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
    }
    
    public func makeNSViewController(context: Context) -> NSViewControllerType {
        .init(data: data,
              content: content,
              contextMenu: contextMenu,
              selectionChanged: { selection = $0 })
    }
    
    public func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        nsViewController.setupColumns(columns)
        nsViewController.updateData(newValue: data)
        nsViewController.changeSelectedItem(to: selection)
        nsViewController.tableView.onDoubleClicked = onDoubleClicked
        nsViewController.tableView.usesAlternatingRowBackgroundColors = usingAlternatingRowBackgroundColors
        nsViewController.delegate.itemsChanged = { data = $0 }
        
        nsViewController.tableView.gridColor = .gridColor
        nsViewController.tableView.gridStyleMask = drawingRowSeperators ? .solidHorizontalGridLineMask : []
        nsViewController.tableView.allowsMultipleSelection = allowingMultipleSelection
        
        if hidingHeader {
            nsViewController.tableView.headerView = nil
        }
    }
}

extension SwiftUIList where Data.Element: ListItemKind {
    public init(_ data: Binding<Data>,
                selection: Binding<Set<Data.Element>>,
                content: @escaping ListItemContentType<Data>) {
        self._data = data
        self._selection = selection
        self.content = content
        self.allowingMultipleSelection = true
    }
    
    
}
