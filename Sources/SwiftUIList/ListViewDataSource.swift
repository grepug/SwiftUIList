//
//  ListViewDataSource.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import AppKit

class ListViewDataSource<Data: Sequence>: NSObject, NSTableViewDataSource where Data.Element: Identifiable {
    var items: [ListItem<Data>] = []
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        print("count", items.count)
        return items.count
    }
}

