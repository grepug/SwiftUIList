import SwiftUI
import AppKit

public struct SwiftUIList<Data: Sequence>: NSViewControllerRepresentable where Data.Element: DataElement {
    public typealias NSViewControllerType = ListViewController<Data>
    
    @Binding var data: Data
    @Binding var selection: Set<Data.Element>
    var childrenKeyPath: ChildrenKeyPath<Data>?
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
    
    public init(_ data: Binding<Data>,
                selection: Binding<Set<Data.Element>>,
                children: ChildrenKeyPath<Data>? = nil,
                content: @escaping ListItemContentType<Data>) {
        self._data = data
        self._selection = selection
        self.content = content
        self.childrenKeyPath = children
        self.allowingMultipleSelection = true
    }
    
    public func makeNSViewController(context: Context) -> NSViewControllerType {
        .init(data: data,
              childrenKeyPath: childrenKeyPath,
              content: content,
              contextMenu: contextMenu,
              selectionChanged: { selection = $0 },
              itemsChanged: { items in
            DispatchQueue.main.async {
                data = items.map(\.value) as! Data
            }
        })
    }
    
    public func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        nsViewController.setupColumns(columns)
        nsViewController.updateData(newValue: data, children: childrenKeyPath)
        nsViewController.changeSelectedItem(to: selection)
        nsViewController.tableView.onDoubleClicked = onDoubleClicked
        nsViewController.tableView.usesAlternatingRowBackgroundColors = usingAlternatingRowBackgroundColors
        
        nsViewController.tableView.gridColor = .gridColor
        nsViewController.tableView.gridStyleMask = drawingRowSeperators ? .solidHorizontalGridLineMask : []
        nsViewController.tableView.allowsMultipleSelection = allowingMultipleSelection
        
        if hidingHeader {
            nsViewController.tableView.headerView = nil
        }
    }
}
