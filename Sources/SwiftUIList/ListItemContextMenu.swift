//
//  ListItemContextMenu.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import Foundation

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
