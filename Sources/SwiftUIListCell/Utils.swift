//
//  Utils.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit
import SwiftUI
import Combine
import SwiftUIList

public protocol CellWrappable: View {
    var doubleClickSubject: PassthroughSubject<Void, Never> { get }
}

public extension CellWrappable {
    var nsView: NSHostingView<Self> {
        .init(rootView: self)
    }
}

public extension NSView {
    func cell<Content: CellWrappable>(of type: Content.Type) -> Content? {
        (self as? NSHostingView<Content>)?.rootView ??
        subviews(ofType: NSHostingView<Content>.self).first?.rootView
    }
}

public extension NSView {
    func subviews<T: NSView>(ofType type: T.Type) -> [T] {
        var result = subviews.compactMap { $0 as? T }
        
        for sub in subviews {
            result.append(contentsOf: sub.subviews(ofType: type))
        }
        
        return result
    }
}

public extension SwiftUIList {
    
}
