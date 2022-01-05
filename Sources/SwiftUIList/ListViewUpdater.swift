//
//  ListViewUpdater.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import Foundation
import AppKit

struct ListViewUpdater<Data: Sequence> where Data.Element: Identifiable {
    func performUpdates(tableView: NSTableView,
                        oldState: [ListItem<Data>]?,
                        newState: [ListItem<Data>]?) {
        let oldUnwrappedState = oldState ?? []
        let newUnwrappedState = newState ?? []
        
        guard oldState != nil || newState != nil else {
            return
        }
        
        let diff = newUnwrappedState.difference(from: oldUnwrappedState, by: { $0.id == $1.id })
        
        if !diff.isEmpty || oldState != newState {
            
        }
        
        for change in diff {
            switch change {
            case .insert(offset: let offset, _, _):
                tableView.insertRows(at: [offset], withAnimation: .effectFade)
            case .remove(offset: let offset, _, _):
                tableView.removeRows(at: [offset], withAnimation: .effectFade)
            }
        }
    }
}
