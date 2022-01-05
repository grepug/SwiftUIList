//
//  ListItem.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import Foundation

public struct ListItem<Data: Sequence>: Identifiable & Equatable & Hashable where Data.Element: Identifiable {
    public static func == (lhs: ListItem<Data>, rhs: ListItem<Data>) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var value: Data.Element
    public var id: Data.Element.ID { value.id }
    
    init(_ value: Data.Element) {
        self.value = value
    }
}
