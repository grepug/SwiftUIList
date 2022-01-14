//
//  ContextMenuItem.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit

public struct ContextMenuItem {
    public init(_ kind: ContextMenuItem.Kind,
                keyEquivalent: String = "",
                action: (() -> Void)? = nil,
                children: [ContextMenuItem]? = nil) {
        self.kind = kind
        self.action = action
        self.children = children
        self.keyEquivalent = keyEquivalent
    }
    
    public struct MenuCustomView {
        public init(_ view: NSView, width: CGFloat, height: CGFloat) {
            view.frame = .init(x: 0, y: 0, width: width, height: height)
            self.view = view
        }
        
        let view: NSView
    }
    
    public enum Kind {
        case title(String), view(MenuCustomView), separator
    }
    
    let id = UUID().uuidString
    var keyEquivalent: String
    var kind: Kind
    var action: (() -> Void)?
    var children: [Self]?
    
    public static let separator: Self = .init(.separator)
}
