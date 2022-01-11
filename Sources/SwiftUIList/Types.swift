//
//  Types.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit
import SwiftUI
import Combine

public typealias DataElement = Hashable & Identifiable
public typealias ListItemContentType<Item: DataElement> = (Int, Int, Binding<Item>) -> NSView
public typealias ContextMenu<Item: DataElement> = ((Item, Int, Int) -> [ListItemContextMenu])
public typealias OperationSubject<Item: DataElement> = PassthroughSubject<ListOperation<Item>, Never>
public typealias ItemChange<Item: DataElement> = (Int, Int, Item) -> Void
public typealias ChildrenKeyPath<Item> = ReferenceWritableKeyPath<Item, [Item]?>
public typealias DataChange<Item> = ([Item]) -> Void

typealias SelectionChanged<Item: DataElement> = (Set<Item>) -> Void
