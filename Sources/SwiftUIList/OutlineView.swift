//
//  OutlineView.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import AppKit

class OutlineView<Item: DataElement>: NSOutlineView {
    typealias Data = [Item]
    
    var items: Data
    var contextMenu: ContextMenu<Item>?
    var onDoubleClicked: ((Int, Int, NSView) -> Void)?
    
    private let menuHandler = MenuHandler()
    
    init(items: Data,
         contextMenu: ContextMenu<Item>? = nil) {
        self.items = items
        self.contextMenu = contextMenu
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
                
            if targetRow % 2 != 0 && usesAlternatingRowBackgroundColors {
                contextualRect = .init(x: rect.origin.x,
                                       y: rect.origin.y - 2.5,
                                       width: rect.width,
                                       height: rect.height + 5)
            } else {
                contextualRect = rect
            }
        }
        
        setNeedsDisplay(contextualRect) // Draw the highlight rectangle if necessary.
        
        let row = row(for: event)
        let col = column(for: event)
        
        guard row > -1 else { return nil }
        
        let item = item(atRow: row) as! Item
        let childIndex = childIndex(forItem: item)
        let parent = parent(forItem: item) as? Item
        let contextMenuInfo = ContextMenuInfo(item: item, parent: parent, childIndex: childIndex, column: col)
        let contextMenu = contextMenu?(contextMenuInfo) ?? []
        let menu = menuHandler.makeContextMenu(contextMenu: contextMenu)
        
        return menu
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let row = row(for: event)
        
        guard row > -1 else { return }
        
        let col = column(for: event)
        let view = view(atColumn: col, row: row, makeIfNecessary: false)!
        
        if event.clickCount == 2 {
            onDoubleClicked?(row, col, view)
        }
        
        if !contextualRect.isEmpty {
            // Clear the highlight if the user clicks away from the menu.
            contextualRect = NSRect()
            setNeedsDisplay(contextualRect)
        }
        
        if let textField = view.subviews(ofType: NSTextField.self).first {
            textField.mouseDown(with: event)
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
}

public extension NSView {
    func subviews<T: NSView>(ofType type: T.Type) -> [T] {
        var result = subviews.compactMap { $0 as? T }
        
        for sub in subviews {
            result.append(contentsOf: sub.subviews(ofType: type))
        }
        
        return result
    }
}
