//
//  ListItemColumn.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import Foundation

public struct ListItemColumn {
    public init(id: String = UUID().uuidString, title: String, width: CGFloat? = nil, fixedWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minWidth: CGFloat? = nil) {
        self.id = id
        self.title = title
        self.width = width
        self.fixedWidth = fixedWidth
        self.maxWidth = maxWidth
        self.minWidth = minWidth
    }
    
    var id = UUID().uuidString
    let title: String
    var width: CGFloat?
    var fixedWidth: CGFloat?
    var maxWidth: CGFloat?
    var minWidth: CGFloat?
}
