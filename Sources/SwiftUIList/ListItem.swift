//
//  ListItem.swift
//  
//
//  Created by Kai on 2022/1/5.
//

import Foundation

public protocol ListItemKind: Hashable, Identifiable {
    var children: [Self]? { get set }
}

extension ListItemKind {
    func isEqual(to item: Self) -> Bool {
        item.id == id
    }
}

//public struct ListItem<Data: Collection>: Identifiable & Hashable where Data.Element: DataElement {
//    public static func == (lhs: ListItem<Data>, rhs: ListItem<Data>) -> Bool {
//        lhs.value == rhs.value
//    }
//    
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(value)
//    }
//    
//    var value: Data.Element
//    var childrenPath: ChildrenKeyPath<Data>?
//    
//    public var id: Data.Element.ID { value.id }
//    
//    var children: [Self]? {
//        get {
//            if let childrenPath = childrenPath {
//                return value[keyPath: childrenPath]?.map { Self($0, children: childrenPath) }
//            }
//            
//            return nil
//        }
//        
//        set {
//            if let childrenPath = childrenPath {
//                value[keyPath: childrenPath] = newValue?.map(\.value) as? Data
//            }
//        }
//    }
//    
//    init(_ value: Data.Element,
//         children: ChildrenKeyPath<Data>? = nil) {
//        self.value = value
//        self.childrenPath = children
//    }
//}
