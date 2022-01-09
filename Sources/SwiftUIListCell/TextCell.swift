//
//  TextCell.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import SwiftUI
import AppKit
import Combine

public struct TextCell: CellWrappable {
    @State private var isEditing: Bool = false
    @State private var internalText: String
    
    private var textValidator: TextValidator?
    private var canEdit: Bool = true
    private var onChange: ((String) -> Void)?
    private var onDoubleClick: (() -> Void)?
    
    @EnvironmentObject private var cell: CellWrapper<Self>
    
    public init(_ text: Binding<String>,
                textValidator: TextValidator? = nil) {
        self.textValidator = textValidator
        self._internalText = State(initialValue: text.wrappedValue)
        self.onChange = { string in
            text.wrappedValue = string
        }
    }
    
    public init(_ text: String,
                onDoubleClick: (() -> Void)? = nil) {
        self._internalText = State(initialValue: text)
        self.canEdit = false
        self.onDoubleClick = onDoubleClick
    }
    
    public init<Item>(item: Binding<Item>,
                      double: ReferenceWritableKeyPath<Item, Double>,
                      onChange: @autoclosure @escaping (() -> Void)) {
        self._internalText = State(initialValue: item.wrappedValue[keyPath: double].toString(fixedAndDroppingZeros: 2))
        self.onChange = { string in
            item.wrappedValue[keyPath: double] = Double(string) ?? 0
            onChange()
        }
        self.textValidator = .double
    }
    
    public var body: some View {
        TextCellView(text: $internalText,
                     validator: textValidator,
                     canEdit: canEdit) {
            onChange?(internalText)
        } onDoubleClick: {
            onDoubleClick?()
        }
    }
}
