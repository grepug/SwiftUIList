//
//  ListItemContextMenu.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit

public struct ListItemContextMenu {
    public init(title: String = "",
                view: NSView? = nil,
                kind: ListItemContextMenu.Kind = .menu,
                action: (() -> Void)? = nil,
                children: [ListItemContextMenu]? = nil) {
        self.title = title
        self.view = view
        self.kind = kind
        self.action = action
        self.children = children
    }
    
    public enum Kind {
        case menu, separator
    }
    
    let id = UUID().uuidString
    let title: String
    var view: NSView?
    var kind: Kind = .menu
    var action: (() -> Void)?
    var children: [Self]?
    
    public static let separator: Self = .init(title: "", kind: .separator)
}
