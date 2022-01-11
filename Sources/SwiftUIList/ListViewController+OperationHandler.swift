//
//  ListViewController+OperationHandler.swift
//  
//
//  Created by Kai on 2022/1/8.
//

import AppKit

extension ListViewController {
    private func children(of parent: Item?) -> [Item]? {
        if let parent = parent, let keyPath = childrenKeyPath {
            return parent[keyPath: keyPath]
        }
        
        return nil
    }
    
    func operationHandler(operation: ListOperation<Item>, outlineView: OutlineView<Item>) {
        var oldData = dataSource.items
        
        switch operation {
        case .reload(data: let data):
            dataSource.items = data
            dataChanged(data)
            outlineView.reloadData()
        case .reloadItem(let item, reloadingChildren: let reloadChildren):
            outlineView.reloadItem(item, reloadChildren: reloadChildren)
        case .insert(let item, after: let afterItem):
            let parent: Item?
            let index: Int
            
            if let afterItem = afterItem {
                parent = outlineView.parent(forItem: afterItem) as? Item
                index = (children(of: parent) ?? oldData).firstIndex(of: afterItem)! + 1
            } else {
                parent = nil
                index = dataSource.items.endIndex
            }
            
            if let parent = parent, let keyPath = childrenKeyPath {
                parent[keyPath: keyPath]?.insert(item, at: index)
            } else {
                dataSource.items.insert(item, at: index)
                dataChanged(oldData)
            }
            
            outlineView.insertItems(at: [index], inParent: parent, withAnimation: .effectFade)
        case .insertBefore(let item, before: let beforeItem):
            let parent: Item?
            let index: Int
            
            if let beforeItem = beforeItem {
                parent = outlineView.parent(forItem: beforeItem) as? Item
                index = (children(of: parent) ?? oldData).firstIndex(of: beforeItem)! - 1
            } else {
                parent = nil
                index = oldData.endIndex
            }
            
            if let parent = parent, let keyPath = childrenKeyPath {
                parent[keyPath: keyPath]?.insert(item, at: index)
            } else {
                dataSource.items.insert(item, at: index)
                dataChanged(oldData)
            }
            
            outlineView.insertItems(at: [index], inParent: parent, withAnimation: .effectFade)
        case .insert2(let item, offset: let index, parent: let parent):
            if let parent = parent, let keyPath = childrenKeyPath {
                parent[keyPath: keyPath]?.insert(item, at: index)
            } else {
                dataSource.items.insert(item, at: index)
                dataChanged(oldData)
            }
            
            outlineView.insertItems(at: [index], inParent: parent, withAnimation: .effectFade)
        case .insertChild(let item, inParent: let parent):
            if let parent = parent, let keyPath = childrenKeyPath {
                parent[keyPath: keyPath] = parent[keyPath: keyPath] ?? []
                let children = parent[keyPath: keyPath]!
                parent[keyPath: keyPath]?.insert(item, at: children.endIndex)
                
                outlineView.reloadItem(parent, reloadChildren: true)
                outlineView.expandItem(parent)
            } else {
                
            }
        case .remove(let item, shouldRemove: let shouldRemove):
            if shouldRemove {
                let parent = outlineView.parent(forItem: item) as? Item
                let index = (children(of: parent) ?? oldData).firstIndex(of: item)!
                
                if let parent = parent, let keyPath = childrenKeyPath {
                    parent[keyPath: keyPath]?.remove(at: index)
                } else {
                    oldData.remove(at: index)
                    dataChanged(oldData)
                }
            }
            
            let index = outlineView.childIndex(forItem: item)
            let parent = outlineView.parent(forItem: item)

            outlineView.removeItems(at: [index], inParent: parent, withAnimation: .effectFade)
        case .reorder(let items, parent: let parent):
            guard !items.isEmpty else { return }
            
            let oldItems = outlineView.items(ofItem: parent)
            let diff = items.difference(from: oldItems, by: { $0.id == $1.id }).inferringMoves()
            
            for change in diff {
                switch change {
                case .insert(offset: let offset, element: _, associatedWith: let prevOffset):
                    if let prevOffset = prevOffset {
                        outlineView.moveItem(at: prevOffset, inParent: parent, to: offset, inParent: parent)
                    }
                default: break
                }
            }
        case .becomeFirstResponder(let item, column: let column):
            let row = outlineView.row(forItem: item)
            let view = outlineView.view(atColumn: column, row: row, makeIfNecessary: false)
            
            if let textField = view?.subviews(ofType: NSTextField.self).first {
                textField.becomeFirstResponder()
            }
        case .expand(let item, expandChildren: let expandChildren):
            DispatchQueue.main.async {
                outlineView.expandItem(item, expandChildren: expandChildren)
            }
        case .move(let item, to: let targetParent):
            if let parent = outlineView.parent(forItem: item) as? Item {
                let index = outlineView.childIndex(forItem: item)
                outlineView.removeItems(at: [index], inParent: parent, withAnimation: .effectFade)
            } else {
                let index = outlineView.childIndex(forItem: item)
                outlineView.removeItems(at: [index], inParent: parent, withAnimation: .effectFade)
            }
            
            outlineView.reloadItem(targetParent, reloadChildren: true)
            
            DispatchQueue.main.async {
                outlineView.expandItem(targetParent, expandChildren: false)
            }
        }
    }
}

extension OutlineView {
    func items(ofItem item: Item?) -> [Item] {
        var items = [Item]()
        let numberOfChildren = numberOfChildren(ofItem: item)
        
        for index in 0..<numberOfChildren {
            items.append(child(index, ofItem: item) as! Item)
        }
        
        return items
    }
    
    
    func remove(prevItems: [Item],
                currentItems: [Item],
                inParent parent: Item?) {
        let diff = currentItems.difference(from: prevItems)
        
        for change in diff.steps {
            switch change {
            case .remove(_, at: let index):
                removeItems(at: [index], inParent: parent, withAnimation: .effectFade)
            default: break
            }
        }
    }
}

