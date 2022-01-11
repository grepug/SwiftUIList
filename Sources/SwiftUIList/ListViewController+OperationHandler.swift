//
//  ListViewController+OperationHandler.swift
//  
//
//  Created by Kai on 2022/1/8.
//

import AppKit

public struct ListItemInsertionInfo<Item: DataElement> {
    public init(prevIds: [Item.ID], ids: [Item.ID]) {
        self.prevIds = prevIds
        self.ids = ids
    }
    
    let prevIds: [Item.ID]
    let ids: [Item.ID]
    
    var insertedIndexSet: IndexSet {
        var indexSet = IndexSet()
        
        for change in ids.difference(from: prevIds).steps {
            switch change {
            case .insert(_, at: let index):
                indexSet.insert(index)
            default: break
            }
        }
        
        return indexSet
    }
}

public struct ListItemRemovalInfo<Item: DataElement> {
    public init(removed: Bool, index: Int) {
        self.removed = removed
        self.index = index
    }
    
    let removed: Bool
    let index: Int
}

extension ListViewController {
    private func children(of parent: Item?) -> [Item]? {
        if let parent = parent, let keyPath = childrenKeyPath {
            return parent[keyPath: keyPath]
        }
        
        return nil
    }
    
    func operationHandler(operation: ListOperation<Item>, outlineView: OutlineView<Item>) {
        switch operation {
        case .reload(data: let data):
            dataSource.items = data
            dataChanged(data)
            outlineView.reloadData()
        case .reloadItem(let item, reloadingChildren: let reloadChildren):
            outlineView.reloadItem(item, reloadChildren: reloadChildren)
        case .inserted(let indexSet, parent: let parent):
            outlineView.insertItems(at: indexSet, inParent: parent, withAnimation: .effectFade)
            outlineView.expandItem(parent)
        case .removed(let index, parent: let parent):
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
        case .moved(let index, parent: let parent, toIndex: let toIndex, toParent: let toParent):
            outlineView.moveItem(at: index, inParent: parent, to: toIndex, inParent: toParent)
            
            if let parent = toParent {
                outlineView.reloadItem(parent)
            } else {
                outlineView.reloadData()
            }
            
            outlineView.expandItem(toParent)
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

