//
//  Types.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit
import SwiftUI

public typealias DataElement = ListItemKind
public typealias ListItemContentType<Item: DataElement> = (Int, Int, Binding<Item>) -> NSView
public typealias ContextMenu<Item: DataElement> = ((Item, Int, Int) -> [ListItemContextMenu])
public typealias ItemsChanged<Item> = ([Item]) -> Void

public protocol OutlineItem: DataElement {
    var children: [Self]? { get set }
}

typealias SelectionChanged<Item: DataElement> = (Set<Item>) -> Void
