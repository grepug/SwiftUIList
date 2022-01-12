//
//  File.swift
//  
//
//  Created by Kai on 2022/1/11.
//

import Foundation
import CoreData

public enum ListOperation<Item: DataElement> {
    case inserted(IndexSet, parent: Item?)
    case removed(Int, parent: Item?)
    case reload(data: [Item])
    case reloadItem(Item?, reloadingChildren: Bool)
    case reorder([Item], parent: Item?)
    case becomeFirstResponder(Item, column: Int)
    case expand(Item?, expandChildren: Bool)
    case moved(Int, parent: Item?, toIndex: Int, toParent: Item?)
}

public protocol ListViewOperable {
    associatedtype Item: DataElement
    
    func items() -> [Item]
    func updateView()
    
    func _remove(item: Item, inParent parent: Item?, at index: Int, shouldDelete: Bool)
    func _insert(item: Item, into parent: Item?) -> ListItemInsertionInfo<Item>
    
    static var operations: OperationSubject<Item> { get }
}

public extension ListViewOperable {
    func reloadList(withItems _items: [Item]? = nil) {
        DispatchQueue.main.async {
            let items = _items ?? items()
            
            Self.operations.send(.reload(data: items))
        }
    }
    
    func expand(item: Item? = nil) {
        Self.operations.send(.expand(item, expandChildren: item == nil))
    }
    
    func reloadItem(_ item: Item, reloadingChildren: Bool = false) {
        Self.operations.send(.reloadItem(item, reloadingChildren: reloadingChildren))
    }
    
    private func indexSetForInsertion(_ item: Item, into parent: Item?) -> IndexSet {
        let info = _insert(item: item, into: parent)
        let diff = info.ids.difference(from: info.prevIds)
        var indexSet = IndexSet()
        
        for change in diff.steps {
            switch change {
            case .insert(_, at: let index):
                indexSet.insert(index)
            default: break
            }
        }
        
        return indexSet
    }
    
    func insertItem(_ item: Item, into parent: Item?) {
        let info = _insert(item: item, into: parent)
        
        DispatchQueue.main.async {
            Self.operations.send(.inserted(info.insertedIndexSet, parent: parent))
        }
    }
    
    func removeItem(_ item: Item, inParent parent: Item?, at index: Int) {
        _remove(item: item, inParent: parent, at: index, shouldDelete: true)
        Self.operations.send(.removed(index, parent: parent))
    }
    
    func moveItem(_ item: Item, inParent parent: Item?, at index: Int, to targetParent: Item?) {
        _remove(item: item, inParent: parent, at: index, shouldDelete: false)
        let info = _insert(item: item, into: targetParent)

        DispatchQueue.main.async {
            Self.operations.send(.moved(index, parent: parent, toIndex: info.insertedIndexSet.first!, toParent: targetParent))
        }
    }
    
    func reorderItems(newItems _items: [Item]? = nil, inParent parent: Item? = nil) {
        DispatchQueue.main.async {
            let items = _items ?? items()
            Self.operations.send(.reorder(items, parent: parent))
        }
    }
    
    func becomeFirstResponder(item: Item, atColumn column: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            Self.operations.send(.becomeFirstResponder(item, column: column))
        }
    }
}

public extension ListViewOperable {
    func makeMoveToMenu<T>(item: Item,
                           children: KeyPath<Item, T>,
                           title: @escaping (Item?) -> String,
                           action: @escaping (Item?) -> Void) -> [ListItemContextMenu] {
        let list = Self.makeMoveToList(fromItem: item,
                                       children: items(),
                                       childrenKeyPath: children)
        
        let rootItem = ListItemContextMenu(title: title(nil)) {
            action(nil)
        }
        
        return [rootItem] + list.map { item, level in
            let spacings = Array(repeating: "    ", count: level).joined(separator: "")
            let title = spacings + title(item)
            
            return .init(title: title) {
                action(item)
            }
        }
    }
    
    private static func makeMoveToList<T>(fromItem: Item,
                                  children: [Item],
                                  childrenKeyPath: KeyPath<Item, T>,
                                  level: Int = 0) -> [(Item, Int)] {
        var list = [(Item, Int)]()
        
        for item in children {
            guard item.id != fromItem.id else { continue }
            
            list.append((item, level))
            
            if let childrenOptional = item[keyPath: childrenKeyPath] as? [Item]?,
               let children = childrenOptional {
                list.append(contentsOf: makeMoveToList(fromItem: fromItem,
                                                       children: children,
                                                       childrenKeyPath: childrenKeyPath,
                                                       level: level + 1))
            }
        }
        
        return list
    }
}
