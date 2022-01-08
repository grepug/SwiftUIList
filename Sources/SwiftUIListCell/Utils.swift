//
//  Utils.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import AppKit
import SwiftUI
import Combine

public protocol CellWrappable: View {
    var doubleClickSubject: PassthroughSubject<Void, Never> { get }
}

public extension CellWrappable {
    var nsView: NSView {
        CellWrapper(rootView: self)
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

extension Double {
    func toString(toFixed fixed: Int, dropingDotZero: Bool = false) -> String {
        let string = String(format: "%.\(fixed)f", self)
        let decimal = truncatingRemainder(dividingBy: 1)
        
        if dropingDotZero && decimal == 0 {
            return String(Int(self))
        }
        
        return string
    }
    
    func toString(fixedAndDroppingZeros fixed: Int) -> String {
        var string = toString(toFixed: fixed, dropingDotZero: true)
        
        if string.contains(".") {
            while string.last == "0" {
                string = String(string.dropLast())
            }
        }
        
        return string
    }
}

public struct TextValidator {
    var isValid: (String) -> Bool
    var formatted: (String) -> String
}

public extension TextValidator {
    static var int: Self {
        .init { string in
            string.isInt || string.isEmpty
        } formatted: { string in
            String(Int(string) ?? 0)
        }
    }
    
    static var double: Self {
        .init { string in
            string.isDouble || string.isEmpty
        } formatted: { string in
            (Double(string) ?? 0).toString(fixedAndDroppingZeros: 2)
        }
    }
}

extension StringProtocol {
    var double: Double? { Double(self) }
    var integer: Int? { Int(self) }
    
    var isDouble: Bool { double != nil }
    var isInt: Bool { integer != nil }
}

