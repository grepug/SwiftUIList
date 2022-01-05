import SwiftUI
import AppKit

public typealias ListItemContentType<Data: Sequence> = (Int, Int, Data.Element) -> NSView where Data.Element: Identifiable

public struct SwiftUIList<Data: Sequence>: NSViewControllerRepresentable where Data.Element: Identifiable {
    public typealias NSViewControllerType = ListViewController<Data>
    
    let data: Data
    @Binding var selection: Data.Element?
    var contextMenus: ((Data.Element, Int, Int) -> [ListItemContextMenu])?
    var columns: [ListItemColumn] = [.init(title: "")]
    var content: ListItemContentType<Data>
    var onDoubleClicked: ((Int, Int, NSView) -> Void)?
    var hidingHeader = false
    
    public init(_ data: Data,
                selection: Binding<Data.Element?>,
                content: @escaping ListItemContentType<Data>) {
        self.data = data
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
        
        if hidingHeader {
            nsViewController.tableView.headerView = nil
        }
    }
}

public extension SwiftUIList {
    func onDoubleClick(action: @escaping (Int, Int, NSView) -> Void) -> Self {
        var mutableSelf = self
        mutableSelf.onDoubleClicked = action
        
        return mutableSelf
    }
    
    func contextMenu(menu: @escaping (Data.Element, Int, Int) -> [ListItemContextMenu]) -> Self {
        var mutableSelf = self
        mutableSelf.contextMenus = menu
        
        return mutableSelf
    }
    
    func columns(_ columns: [ListItemColumn]) -> Self {
        var mutableSelf = self
        mutableSelf.columns = columns
        
        return mutableSelf
    }
    
    func headerHidden() -> Self {
        var mutableSelf = self
        mutableSelf.hidingHeader = true
        
        return mutableSelf
    }
}

public struct ListItemContextMenu {
    public init(title: String, kind: ListItemContextMenu.Kind = .menu, action: (() -> Void)? = nil, children: [ListItemContextMenu]? = nil) {
        self.title = title
        self.kind = kind
        self.action = action
        self.children = children
    }
    
    public enum Kind {
        case menu, separator
    }
    
    let id = UUID().uuidString
    let title: String
    var kind: Kind = .menu
    var action: (() -> Void)?
    var children: [Self]?
    
    public static let separator: Self = .init(title: "", kind: .separator)
}

public struct ListItemColumn {
    public init(id: String = UUID().uuidString, title: String, width: CGFloat? = nil, fixedWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minWidth: CGFloat? = nil) {
        self.id = id
        self.title = title
        self.width = width
        self.fixedWidth = fixedWidth
        self.maxWidth = maxWidth
        self.minWidth = minWidth
    }
    
    var id = UUID().uuidString
    let title: String
    var width: CGFloat?
    var fixedWidth: CGFloat?
    var maxWidth: CGFloat?
    var minWidth: CGFloat?
}
