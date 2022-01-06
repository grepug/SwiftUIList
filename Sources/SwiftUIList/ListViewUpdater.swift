//
//  ListViewUpdater.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import Foundation
import AppKit

struct ListViewUpdater<Data: Sequence> where Data.Element: DataElement {
    func performUpdates(tableView: NSOutlineView,
                        oldState: [ListItem<Data>]?,
                        newState: [ListItem<Data>]?,
                        parent: ListItem<Data>?) {
        let oldUnwrappedState = oldState ?? []
        let newUnwrappedState = newState ?? []
        
        guard oldState != nil || newState != nil else {
            return
        }
        
        let diff = newUnwrappedState.difference(from: oldUnwrappedState, by: { $0 == $1 })
        
        if !diff.isEmpty || oldState != newState, let parent = parent {
            tableView.reloadItem(parent, reloadChildren: false)
        }
        
        var removedElements = [ListItem<Data>]()
        var insertIndexSet = IndexSet()
        var removeIndexSet = IndexSet()
        
        for change in diff {
            switch change {
            case .insert(offset: let offset, element: _, _):
                insertIndexSet.insert(offset)
            case .remove(offset: let offset, element: let item, _):
                removedElements.append(item)
                removeIndexSet.insert(offset)
            }
        }
        
        let reloadIndexSet = insertIndexSet.intersection(removeIndexSet)
        insertIndexSet = insertIndexSet.subtracting(reloadIndexSet)
        removeIndexSet = removeIndexSet.subtracting(reloadIndexSet)
        let itemsShouldReload = itemsShouldReload(in: diff, offsets: reloadIndexSet)
        
        tableView.insertItems(at: insertIndexSet, inParent: parent, withAnimation: .effectFade)
        tableView.removeItems(at: removeIndexSet, inParent: parent, withAnimation: .effectFade)
        itemsShouldReload.forEach { tableView.reloadItem($0) }
        
        var oldUnchangedElements = oldUnwrappedState.dictionaryFromIdentity()
        removedElements.forEach { oldUnchangedElements.removeValue(forKey: $0.id) }

        let newStateDict = newUnwrappedState.dictionaryFromIdentity()

        oldUnchangedElements
            .keys
            .map { (oldUnchangedElements[$0].unsafelyUnwrapped, newStateDict[$0].unsafelyUnwrapped) }
            .map { (tableView, $0.0.children, $0.1.children, $0.1) }
            .forEach(performUpdates)
    }
    
    private func itemsShouldReload(in diff: CollectionDifference<ListItem<Data>>, offsets: IndexSet) -> [ListItem<Data>] {
        var items = [ListItem<Data>]()
        
        for change in diff.removals {
            switch change {
            case .remove(offset: let offset, element: let item, associatedWith: _):
                if offsets.contains(offset) {
                    items.append(item)
                }
            default: break
            }
        }
        
        return items
    }
}

fileprivate extension Sequence where Element: Identifiable {
    func dictionaryFromIdentity() -> [Element.ID: Element] {
        Dictionary(map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
    }
}
