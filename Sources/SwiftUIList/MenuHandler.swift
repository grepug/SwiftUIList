//
//  File.swift
//  
//
//  Created by Kai on 2022/1/14.
//

import AppKit

public class MenuHandler: NSObject {
    private var contextMenuActions = [String: () -> Void]()
    
    @objc func handleMenuEvent(_ sender: Any) {
        let menuItem = sender as! NSMenuItem
        let id = menuItem.identifier!.rawValue
        
        contextMenuActions[id]?()
    }
    
    private func makeMenuItem(item: ContextMenuItem) -> NSMenuItem {
        let menuItem: NSMenuItem
        
        switch item.kind {
        case .title(let title):
            menuItem = NSMenuItem(title: title,
                                  action: #selector(handleMenuEvent(_:)),
                                  keyEquivalent: item.keyEquivalent)
            menuItem.target = self
            menuItem.identifier = .init(rawValue: item.id)
        case .view(let viewConfig):
            menuItem = NSMenuItem()
            menuItem.view = viewConfig.view
            menuItem.target = self
            menuItem.action = #selector(handleMenuEvent(_:))
        case .separator:
            menuItem = .separator()
        }
        
        return menuItem
    }
    
    public func makeContextMenu(contextMenu: [ContextMenuItem], menu: NSMenu = .init()) -> NSMenu {
        for item in contextMenu {
            if let children = item.children {
                let childMenu = makeContextMenu(contextMenu: children, menu: .init(title: ""))
                let menuItem = makeMenuItem(item: item)
                
                menuItem.submenu = childMenu
                menu.addItem(menuItem)
            } else {
                let menuItem = makeMenuItem(item: item)
                menu.addItem(menuItem)
                contextMenuActions[item.id] = item.action
            }
        }
        
        return menu
    }
}
