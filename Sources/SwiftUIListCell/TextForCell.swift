//
//  TextCell.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import SwiftUI
import AppKit
import Combine

public struct TextForCell: CellWrappable {
    
    @Binding var text: String
    var textValidator: TextValidator?
    public let doubleClickSubject = PassthroughSubject<Void, Never>()
    
    @State var isEditing: Bool = false
    
    public init(_ text: Binding<String>,
                textValidator: TextValidator? = nil) {
        self._text = text
        self.textValidator = textValidator
    }
    
    public init(_ text: String) {
        self._text = .constant(text)
    }
    
    public init(_ double: Binding<Double>) {
        self._text = .init {
            String(double.wrappedValue)
        } set: { newValue in
            double.wrappedValue = Double(newValue) ?? 0
        }
        self.textValidator = .double
    }
    
    public init(_ int: Binding<Int>) {
        self._text = .init {
            String(int.wrappedValue)
        } set: { newValue in
            int.wrappedValue = Int(newValue) ?? 0
        }
        self.textValidator = .int
    }
    
    public var body: some View {
        TextForCellView(text: $text,
                        isEditing: $isEditing,
                        validator: textValidator)
            .onReceive(doubleClickSubject) { _ in
                isEditing = true
            }
    }
}

public struct TextValidator {
    var isValid: (String) -> Bool
}

public extension TextValidator {
    static var int: Self {
        .init { string in
            string.isNumber || string.isEmpty
        }
    }
    
    static var double: Self {
        .init { string in
            string.isNumber || string.isEmpty
        }
    }
}

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

struct TextForCellView: NSViewRepresentable {
    public typealias NSViewType = NSTextField
    
    @Binding var text: String
    @Binding var isEditing: Bool
    var validator: TextValidator?
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(string: text)
        
        textField.stringValue = text
        textField.isSelectable = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.usesSingleLineMode = false
        textField.cell?.wraps = true
        textField.cell?.isScrollable = false
        textField.delegate = context.coordinator
        
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.isEditable = isEditing
        nsView.stringValue = text
    }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(initialText: text) {
            text = $0
        }
        
        coordinator.validator = validator
        
        return coordinator
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        var onChange: (String) -> Void
        var validator: TextValidator?
        var text: String
        
        init(initialText: String, onChange: @escaping (String) -> Void) {
            self.text = initialText
            self.onChange = onChange
        }
        
        func controlTextDidChange(_ obj: Notification) {
            let textField = obj.object as! NSTextField
            let isValid = validator?.isValid(textField.stringValue) ?? false
            
            if !isValid {
                textField.stringValue = text
            } else {
                onChange(textField.stringValue)
                text = textField.stringValue
            }
        }
    }
}
