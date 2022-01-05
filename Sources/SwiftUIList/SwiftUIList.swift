import SwiftUI
import AppKit

public struct SwiftUIList<Data: Sequence>: NSViewControllerRepresentable where Data.Element: Identifiable {
    public typealias NSViewControllerType = ListViewController<Data>
    
    let data: Data
    @Binding var selection: Data.Element?
    var contextMenus: ((Data.Element, Int, Int) -> [ListItemContextMenu])?
    var content: (Data.Element) -> NSView
    
    public init(_ data: Data,
                selection: Binding<Data.Element?>,
                contextMenus: ((Data.Element, Int, Int) -> [ListItemContextMenu])? = nil,
                content: @escaping (Data.Element) -> NSView) {
        self.data = data
        self._selection = selection
        self.contextMenus = contextMenus
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
    }
}

public struct ListItemContextMenu {
    enum Kind {
        case menu, separator
    }
    
    let id = UUID().uuidString
    let title: String
    var kind: Kind = .menu
    var action: (() -> Void)?
    var children: [Self]?
    
    static let separator: Self = .init(title: "", kind: .separator)
}
