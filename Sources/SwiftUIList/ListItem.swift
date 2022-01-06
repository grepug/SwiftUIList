//
//  ListItem.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import Foundation

public struct ListItem<Data: Sequence>: Identifiable & Equatable & Hashable where Data.Element: DataElement {
    public static func == (lhs: ListItem<Data>, rhs: ListItem<Data>) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var value: Data.Element
    var childrenPath: ChildrenKeyPath<Data>?
    
    public var id: Data.Element.ID { value.id }
    
    var children: [Self]? {
        if let childrenPath = childrenPath {
            return value[keyPath: childrenPath]?.map { Self($0, children: childrenPath) }
        }
        
        return nil
    }
    
    init(_ value: Data.Element,
         children: ChildrenKeyPath<Data>? = nil) {
        self.value = value
        self.childrenPath = children
    }
}
