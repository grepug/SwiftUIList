//
//  Types.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit
import SwiftUI

public typealias DataElement = Identifiable & Hashable
public typealias ListItemContentType<Data: Sequence> = (Int, Int, Binding<Data.Element>) -> NSView where Data.Element: DataElement
public typealias ChildrenKeyPath<Data: Sequence> = KeyPath<Data.Element, Data?> where Data.Element: DataElement
public protocol OutlineItem: DataElement {
    var children: [Self]? { get set }
}

typealias SelectionChanged<Data: Sequence> = (Set<Data.Element>) -> Void where Data.Element: DataElement
