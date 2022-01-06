//
//  File.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import AppKit

class TableView<Data: Sequence>: NSTableView where Data.Element: Identifiable {
    var items: [ListItem<Data>]
    var contextMenus: ((Data.Element, Int, Int) -> [ListItemContextMenu])?
    var onDoubleClicked: ((Int, Int, NSView) -> Void)?
    
    private var contextMenuActions = [String: () -> Void]()
    
    init(items: [ListItem<Data>],
         contextMenus: ((Data.Element, Int, Int) -> [ListItemContextMenu])? = nil) {
        self.items = items
        self.contextMenus = contextMenus
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var contextualRect = NSRect()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if !contextualRect.isEmpty {
            // Draw the highlight.
            let rectPath = NSBezierPath(rect: contextualRect)
            let fillColor = NSColor.controlAccentColor
            rectPath.lineWidth = 4
            fillColor.set()
            rectPath.stroke()
        }
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        super.menu(for: event)
        
        // Reset the contextual menu frame for next use.
        contextualRect = NSRect()
 
        let targetRow = row(at: convert(event.locationInWindow, from: nil))
        if targetRow != -1 {
            let rect = rect(ofRow: targetRow)
            
            if targetRow % 2 == 0 {
                contextualRect = rect
            } else {
                contextualRect = .init(x: rect.origin.x,
                                       y: rect.origin.y - 2.5,
                                       width: rect.width,
                                       height: rect.height + 5)
            }
            
            let selectedRowFrame = frameOfCell(atColumn: 0, row: selectedRow)
            if contextualRect.intersects(selectedRowFrame) {
                contextualRect = NSRect()
            }
        }
        
        setNeedsDisplay(contextualRect) // Draw the highlight rectangle if necessary.
        
        let row = row(for: event)
        let col = column(for: event)
        
        guard row > -1 else { return nil }
        
        let item = items[row]
        let contextMenus = contextMenus?(item.value, row, col) ?? []
        let menu = makeContextMenu(contextMenus: contextMenus, menu: NSMenu(title: ""))
        
        return menu
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let row = row(for: event)
        let col = column(for: event)
        
        guard row > -1 else { return }
        
        if event.clickCount == 2 {
            let view = view(atColumn: col, row: row, makeIfNecessary: false)!
            
            onDoubleClicked?(row, col, view)
        }
        
        if !contextualRect.isEmpty {
            // Clear the highlight if the user clicks away from the menu.
            contextualRect = NSRect()
            setNeedsDisplay(contextualRect)
        }
    }
    
    override func didCloseMenu(_ menu: NSMenu, with event: NSEvent?) {
        super.didCloseMenu(menu, with: event)
        
        if !contextualRect.isEmpty {
            // Clear the highlight when the menu closes.
            contextualRect = NSRect()
            setNeedsDisplay(bounds)
        }
    }
    
    @objc func handleMenuEvent(_ sender: Any) {
        let menuItem = sender as! NSMenuItem
        let id = menuItem.identifier!.rawValue
        
        contextMenuActions[id]?()
    }
}

private extension TableView {
    func makeContextMenu(contextMenus: [ListItemContextMenu], menu: NSMenu) -> NSMenu {
        for item in contextMenus {
            if let children = item.children {
                let menuItem = NSMenuItem(title: item.title, action: nil, keyEquivalent: "")
                let childMenu = makeContextMenu(contextMenus: children, menu: .init(title: ""))
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
                    menuItem.identifier = .init(rawValue: item.id)
                }
                
                menu.addItem(menuItem)
                
                contextMenuActions[item.id] = item.action
            }
        }
        
        return menu
    }
}
