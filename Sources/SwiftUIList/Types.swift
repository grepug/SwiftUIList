//
//  Types.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit
import SwiftUI
import Combine

public typealias DataElement = ListItemKind
public typealias ListItemContentType<Item: DataElement> = (Int, Int, Binding<Item>) -> NSView
public typealias ContextMenu<Item: DataElement> = ((Item, Int, Int) -> [ListItemContextMenu])
public typealias OperationSubject<Item: DataElement> = PassthroughSubject<ListOperation<Item>, Never>

public protocol OutlineItem: DataElement {
    var children: [Self]? { get set }
}

typealias SelectionChanged<Item: DataElement> = (Set<Item>) -> Void

public protocol ListItemKind: AnyObject, Hashable, Identifiable {
    var children: [Self]? { get set }
}

public extension ListItemKind {
    func isEqual(to item: Self) -> Bool {
        item.id == id
    }
}

public enum ListOperation<Item: DataElement> {
    case insert(Item, offset: Int, parent: Item?)
    case insert2(Item, after: Item)
    case remove(Item)
}
