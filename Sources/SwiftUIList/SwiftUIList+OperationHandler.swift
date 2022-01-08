//
//  SwiftUIList+OperationHandler.swift
//  
//
//  Created by Kai on 2022/1/8.
//

import AppKit

extension SwiftUIList {
    func operationHandler(operation: ListOperation<Item>, outlineView: NSOutlineView, dataSource: OutlineViewDataSource<Item>) {
        switch operation {
        case .reload(data: let data):
            self.data = data
            outlineView.reloadData()
        case .insert(let item, after: let afterItem):
            let parent: Item?
            let index: Int
            
            if let afterItem = afterItem {
                parent = outlineView.parent(forItem: afterItem) as? Item
                index = (parent?.children ?? data).firstIndex(of: afterItem)! + 1
            } else {
                parent = nil
                index = data.endIndex
            }
            
            if let parent = parent {
                parent.children?.insert(item, at: index)
            } else {
                data.insert(item, at: index)
            }
            
            outlineView.insertItems(at: [index], inParent: parent, withAnimation: .effectFade)
            
        case .insertBefore(let item, before: let beforeItem):
            let parent: Item?
            let index: Int
            
            if let beforeItem = beforeItem {
                parent = outlineView.parent(forItem: beforeItem) as? Item
                index = (parent?.children ?? data).firstIndex(of: beforeItem)! - 1
            } else {
                parent = nil
                index = data.endIndex
            }
            
            if let parent = parent {
                parent.children?.insert(item, at: index)
            } else {
                data.insert(item, at: index)
            }
            
            outlineView.insertItems(at: [index], inParent: parent, withAnimation: .effectFade)
        case .insert2(let item, offset: let offset, parent: let parent):
            if let parent = parent {
                parent.children?.insert(item, at: offset)
            } else {
                data.insert(item, at: offset)
            }
            
            outlineView.insertItems(at: [offset], inParent: parent, withAnimation: .effectFade)
        case .remove(let item):
            let parent = outlineView.parent(forItem: item) as? Item
            let index = (parent?.children ?? data).firstIndex(of: item)!
            
            if let parent = parent {
                parent.children?.remove(at: index)
            } else {
                data.remove(at: index)
            }

            outlineView.removeItems(at: [index], inParent: parent, withAnimation: .effectFade)
        }
    }
}