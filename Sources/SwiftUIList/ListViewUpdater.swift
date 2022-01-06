//
//  ListViewUpdater.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import Foundation
import AppKit
import DifferenceKit

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
        
        for change in diff {
            switch change {
            case .insert(offset: let offset, _, _):
                tableView.insertItems(at: [offset], inParent: parent, withAnimation: .effectFade)
            case .remove(offset: let offset, element: let element, _):
                removedElements.append(element)
                tableView.removeItems(at: [offset], inParent: parent, withAnimation: .effectFade)
            }
        }
        
        var oldUnchangedElements = oldUnwrappedState.dictionaryFromIdentity()
        removedElements.forEach { oldUnchangedElements.removeValue(forKey: $0.id) }

        let newStateDict = newUnwrappedState.dictionaryFromIdentity()

        oldUnchangedElements
            .keys
            .map { (oldUnchangedElements[$0].unsafelyUnwrapped, newStateDict[$0].unsafelyUnwrapped) }
            .map { (tableView, $0.0.children, $0.1.children, $0.1) }
            .forEach(performUpdates)
    }
}

fileprivate extension Sequence where Element: Identifiable {
    func dictionaryFromIdentity() -> [Element.ID: Element] {
        Dictionary(map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
    }
}
