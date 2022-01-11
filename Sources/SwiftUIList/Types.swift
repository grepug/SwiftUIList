//
//  Types.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit
import SwiftUI
import Combine

public typealias DataElement = Hashable & Identifiable
public typealias ListItemContentType<Item: DataElement> = (Int, Int, Binding<Item>) -> NSView
public typealias OperationSubject<Item: DataElement> = PassthroughSubject<ListOperation<Item>, Never>
public typealias ItemChange<Item: DataElement> = (Int, Int, Item) -> Void
public typealias ChildrenKeyPath<Item> = ReferenceWritableKeyPath<Item, [Item]?>
public typealias DataChange<Item> = ([Item]) -> Void
typealias SelectionChanged<Item: DataElement> = (Set<Item>) -> Void

public struct ContextMenuInfo<Item: DataElement> {
    public init(item: Item, parent: Item?, childIndex: Int, column: Int) {
        self.item = item
        self.parent = parent
        self.childIndex = childIndex
        self.column = column
    }
    
    public let item: Item
    public let parent: Item?
    public let childIndex: Int
    public let column: Int
}
public typealias ContextMenu<Item: DataElement> = (ContextMenuInfo<Item>) -> [ListItemContextMenu]
