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

public struct TextForCell: CellWrappable {
    
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
        TextForCellView(text: $text,
                        validator: textValidator)
    }
}

struct TextForCellView: NSViewRepresentable {
    public typealias NSViewType = CustomTextField
    
    @Binding var text: String
    var validator: TextValidator?
    
    func makeNSView(context: Context) -> NSViewType {
        let textField = NSViewType(string: text)
        
        textField.stringValue = text
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.usesSingleLineMode = false
        textField.cell?.wraps = true
        textField.cell?.isScrollable = false
        textField.delegate = context.coordinator
        
        return textField
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
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
            let isValid = validator?.isValid(textField.stringValue) ?? true
            
            if !isValid {
                textField.stringValue = text
            } else {
                let formatted = validator?.formatted(textField.stringValue) ?? textField.stringValue
                
                onChange(formatted)
                text = formatted
                
                textField.stringValue = formatted
            }
        }
    }
}

class CustomTextField: NSTextField {
    override func becomeFirstResponder() -> Bool {
        drawsBackground = true
        
        return super.becomeFirstResponder()
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        
        drawsBackground = false
    }
}
