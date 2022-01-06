import SwiftUI
import AppKit

public typealias ListItemContentType<Data: Sequence> = (Int, Int, Binding<Data.Element>) -> NSView where Data.Element: Identifiable

public struct SwiftUIList<Data: Sequence>: NSViewControllerRepresentable where Data.Element: Identifiable {
    public typealias NSViewControllerType = ListViewController<Data>
    
    @Binding var data: Data
    @Binding var selection: Data.Element?
    var contextMenus: ((Data.Element, Int, Int) -> [ListItemContextMenu])?
    var columns: [ListItemColumn] = [.init(title: "")]
    var content: ListItemContentType<Data>
    var onDoubleClicked: ((Int, Int, NSView) -> Void)?
    var hidingHeader = false
    var usingAlternatingRowBackgroundColors = false
    var drawingRowSeperators = false
    
    public init(_ data: Data,
                selection: Binding<Data.Element?>,
                content: @escaping ListItemContentType<Data>) {
        self._data = .constant(data)
        self._selection = selection
        self.content = content
    }
    
    public init(_ data: Binding<Data>,
                selection: Binding<Data.Element?>,
                content: @escaping ListItemContentType<Data>) {
        self._data = data
        self._selection = selection
        self.content = content
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
        
        if hidingHeader {
            nsViewController.tableView.headerView = nil
        }
    }
}
