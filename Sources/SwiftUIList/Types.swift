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
public typealias ItemChange<Item: DataElement> = (Int, Int, Item) -> Void

typealias SelectionChanged<Item: DataElement> = (Set<Item>) -> Void

public protocol ListItemKind: AnyObject, Hashable, Identifiable {
    
    associatedtype Child: ListItemKind
    
    var children: [Child]? { get set }
}

public extension ListItemKind {
    func isEqual(to item: Self) -> Bool {
        item.id == id
    }
}

public enum ListOperation<Item: DataElement> {
    case insert(Item, after: Item?)
    case insert2(Item, offset: Int, parent: Item?)
    case insertBefore(Item, before: Item?)
    case remove(Item)
    case reload(data: [Item])
    case reorder([Item], parent: Item?)
    case becomeFirstResponder(Item, column: Int)
}

public protocol ListViewOperable {
    associatedtype Item: ListItemKind
    
    func items() -> [Item]
    func updateView()
    
    static var operations: OperationSubject<Item> { get }
}

public extension ListViewOperable {
    func reloadList(withItems _items: [Item]? = nil) {
        DispatchQueue.main.async {
            let items = _items ?? items()
            
            Self.operations.send(.reload(data: items))
        }
    }
    
    func insertItem(_ item: Item, at index: Int, inParent parent: Item? = nil) {
        Self.operations.send(.insert2(item, offset: index, parent: parent))
    }
    
    func insertItem(_ item: Item) {
        Self.operations.send(.insert(item, after: nil))
    }
    
    func insertItem(_ item: Item, before beforeItem: Item) {
        Self.operations.send(.insertBefore(item, before: beforeItem))
    }
    
    func insertItem(_ item: Item, after afterItem: Item?) {
        Self.operations.send(.insert(item, after: afterItem))
    }
    
    func removeItem(_ item: Item) {
        Self.operations.send(.remove(item))
    }
    
    func reorderItems(newItems _items: [Item]? = nil, inParent parent: Item? = nil) {
        DispatchQueue.main.async {
            let items = _items ?? items()
            Self.operations.send(.reorder(items, parent: parent))
        }
    }
    
    func becomeFirstResponder(item: Item, atColumn column: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Self.operations.send(.becomeFirstResponder(item, column: column))
        }
    }
}

public extension ListViewOperable where Item: NSManagedObject {
    func removeItem(_ item: Item) {
        guard let context = item.managedObjectContext else { return }
        
        Self.operations.send(.remove(item))
        context.delete(item)
        try? context.save()
        updateView()
    }
}
