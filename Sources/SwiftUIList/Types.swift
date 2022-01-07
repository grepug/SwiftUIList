//
//  Types.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit
import SwiftUI

public typealias DataElement = ListItemKind
public typealias ListItemContentType<Data: Collection> = (Int, Int, Binding<Data.Element>) -> NSView where Data.Element: DataElement
public typealias ChildrenKeyPath<Data: Collection> = WritableKeyPath<Data.Element, Data?> where Data.Element: DataElement
public typealias ContextMenu<Data: Collection> = ((Data.Element, Int, Int) -> [ListItemContextMenu]) where Data.Element: DataElement
public typealias ItemsChanged<Item> = ([Item]) -> Void

public protocol OutlineItem: DataElement {
    var children: [Self]? { get set }
}

typealias SelectionChanged<Data: Collection> = (Set<Data.Element>) -> Void where Data.Element: DataElement
