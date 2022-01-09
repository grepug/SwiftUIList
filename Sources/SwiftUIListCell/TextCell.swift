//
//  TextCell.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import SwiftUI
import AppKit
import Combine

extension Binding where Value == Double {
    var string: Binding<String> {
        .init {
            return wrappedValue.toString(fixedAndDroppingZeros: 2)
        } set: { newValue in
            wrappedValue = Double(newValue) ?? 0
        }
    }
}

public struct TextCell: CellWrappable {
    
    @Binding var text: String
    var textValidator: TextValidator?
    public let doubleClickSubject = PassthroughSubject<Void, Never>()
    
    @State private var isEditing: Bool = false
    @State private var double: Double = 0
    
    @EnvironmentObject private var cell: CellWrapper<Self>
    
    public init(_ text: Binding<String>,
                textValidator: TextValidator? = nil) {
        self._text = text
        self.textValidator = textValidator
    }
    
    public init(_ text: String) {
        self._text = .constant(text)
    }
    
    public init<Item>(item: Binding<Item>,
                      double: ReferenceWritableKeyPath<Item, Double>,
                      onChange: @autoclosure @escaping (() -> Void)) {
        self._text = .init(get: {
            item.wrappedValue[keyPath: double].toString(fixedAndDroppingZeros: 2)
        }, set: { newValue in
            item.wrappedValue[keyPath: double] = Double(newValue) ?? 0
            onChange()
        })
        
        self.textValidator = .double
    }
    
    public init<Item>(item: Binding<Item>, int: ReferenceWritableKeyPath<Item, Int>) {
        self._text = .init(get: {
            String(item.wrappedValue[keyPath: int])
        }, set: { newValue in
            item.wrappedValue[keyPath: int] = Int(newValue) ?? 0
        })
        
        self.textValidator = .int
    }
    
    public var body: some View {
        TextCellView(text: $text,
                        validator: textValidator)
    }
}
