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
    
    public func makeContextMenu(contextMenu: [ListItemContextMenu], menu: NSMenu = .init()) -> NSMenu {
        for item in contextMenu {
            if let children = item.children {
                let menuItem = NSMenuItem(title: item.title, action: nil, keyEquivalent: "")
                let childMenu = makeContextMenu(contextMenu: children, menu: .init(title: ""))
                menuItem.submenu = childMenu
                
                menu.addItem(menuItem)
            } else {
                let menuItem: NSMenuItem
                
                if item.kind == .separator {
                    menuItem = .separator()
                } else {
                    menuItem = NSMenuItem(title: item.title,
                                          action: #selector(handleMenuEvent(_:)),
                                          keyEquivalent: "")
                    menuItem.target = self
                    menuItem.view = item.view
                    menuItem.identifier = .init(rawValue: item.id)
                }
                
                menu.addItem(menuItem)
                
                contextMenuActions[item.id] = item.action
            }
        }
        
        return menu
    }
}
