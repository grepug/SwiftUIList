//
//  NSTableView+Utils.swift
//  Vision 3 (macOS)
//
//  Created by Kai on 2021/12/15.
//

import AppKit

extension NSTableView {
    func reloadDataWithDiff<Item: Equatable>(before prevItems: [Item], current items: [Item]) {
        let changes = items.difference(from: prevItems)
        
        let insertedRows = changes.insertions.reduce(into: IndexSet()) {
            if case .insert(offset: let offset, _, _) = $1 {
                $0.insert(offset)
            }
        }
        
        let removedRows = changes.removals.reduce(into: IndexSet()) {
            if case .remove(offset: let offset, _, _) = $1 {
                $0.insert(offset)
            }
        }
            
        beginUpdates()
        removeRows(at: removedRows, withAnimation: .effectFade)
        insertRows(at: insertedRows, withAnimation: .effectFade)
        endUpdates()
        
        print("insertedRows", insertedRows)
    }
}

extension NSTableView {
    func point(for event: NSEvent) -> NSPoint {
        let tableViewOrigin = superview!.convert(frame.origin, to: nil)
        return NSPoint(x: abs(event.locationInWindow.x - tableViewOrigin.x),
                       y: abs(event.locationInWindow.y - tableViewOrigin.y))
        
    }
    
    func row(for event: NSEvent) -> Int {
        row(at: point(for: event))
    }
    
    func column(for event: NSEvent) -> Int {
        column(at: point(for: event))
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
