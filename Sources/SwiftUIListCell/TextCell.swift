//
//  TextCell.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import SwiftUI
import AppKit
import Combine

public struct TextCell<LeadingView: View>: CellWrappable {
    @State private var isEditing: Bool = false
    @State private var internalText: String
    
    private var textValidator: TextValidator?
    private var canEdit: Bool = true
    private var onChange: ((String) -> Void)?
    private var onDoubleClick: (() -> Void)?
    private var leadingView: ((Bool) -> LeadingView)?
    
    @EnvironmentObject private var cell: CellWrapper<Self>
    
    public init(_ text: String,
                leadingView: @escaping (Bool) -> LeadingView) {
        self._internalText = State(initialValue: text)
        self.canEdit = false
        self.leadingView = leadingView
    }
    
    public var body: some View {
        if let view = leadingView {
            HStack {
                view(cell.isSelected)
                content
            }
        } else {
            content
        }
    }
    
    var content: some View {
        TextCellView(text: $internalText,
                     validator: textValidator,
                     canEdit: canEdit) {
            onChange?(internalText)
        } onDoubleClick: {
            onDoubleClick?()
        }
    }
}

public extension TextCell where LeadingView == EmptyView {
    init(_ text: Binding<String>,
                textValidator: TextValidator? = nil) {
        self.textValidator = textValidator
        self._internalText = State(initialValue: text.wrappedValue)
        self.onChange = { string in
            text.wrappedValue = string
        }
        self.leadingView = { _ in EmptyView() }
    }
    
    init(_ text: String,
                onDoubleClick: (() -> Void)? = nil) {
        self._internalText = State(initialValue: text)
        self.canEdit = false
        self.onDoubleClick = onDoubleClick
        self.leadingView = { _ in EmptyView() }
    }
    
    init(_ double: Binding<Double>) {
        self._internalText = State(initialValue: double.wrappedValue.toString(fixedAndDroppingZeros: 2))
        self.onChange = { string in
            double.wrappedValue = Double(string) ?? 0
        }
        
        self.textValidator = .double
        self.leadingView = { _ in EmptyView() }
    }
}
