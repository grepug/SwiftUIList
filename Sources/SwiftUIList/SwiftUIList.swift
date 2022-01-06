import SwiftUI
import AppKit

public typealias DataElement = Identifiable & Hashable
public typealias ListItemContentType<Data: Sequence> = (Int, Int, Binding<Data.Element>) -> NSView where Data.Element: DataElement

typealias SelectionChanged<Data: Sequence> = (Set<Data.Element>) -> Void where Data.Element: DataElement

public struct SwiftUIList<Data: Sequence>: NSViewControllerRepresentable where Data.Element: DataElement {
    public typealias NSViewControllerType = ListViewController<Data>
    
    @Binding var data: Data
    @Binding var selection: Set<Data.Element>
    var contextMenus: ((Data.Element, Int, Int) -> [ListItemContextMenu])?
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
                content: @escaping ListItemContentType<Data>) {
        self._data = data
        self._selection = selection
        self.content = content
        self.allowingMultipleSelection = true
    }
    
    public func makeNSViewController(context: Context) -> NSViewControllerType {
        .init(data: data,
              content: content,
              contextMenus: contextMenus,
              selectionChanged: { selection = $0 })
    }
    
    public func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        nsViewController.updateData(newValue: data)
        nsViewController.changeSelectedItem(to: selection)
        nsViewController.setupColumns(columns)
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
