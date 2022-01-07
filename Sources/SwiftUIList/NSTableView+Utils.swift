//
//  NSTableView+Utils.swift
//  Vision 3 (macOS)
//
//  Created by Kai on 2021/12/15.
//

import AppKit

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


