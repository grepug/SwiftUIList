//
//  File.swift
//  
//
//  Created by Kai on 2022/1/9.
//

import AppKit
import SwiftUI

public struct TextCellView: NSViewRepresentable {
    public typealias NSViewType = CustomTextField
    
    @Binding var text: String
    var validator: TextValidator?
    var canEdit: Bool
    
    public init(text: Binding<String>, validator: TextValidator? = nil, canEdit: Bool = true) {
        self._text = text
        self.validator = validator
        self.canEdit = canEdit
    }
    
    public func makeNSView(context: Context) -> NSViewType {
        let textField = NSViewType(string: text)
        
        textField.stringValue = text
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.usesSingleLineMode = false
        textField.cell?.wraps = true
        textField.cell?.isScrollable = false
        textField.delegate = context.coordinator
        textField.isEditable = canEdit
        textField.isSelectable = canEdit
        
        return textField
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.stringValue = text
    }
    
    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(initialText: text) {
            text = $0
        }
        
        coordinator.validator = validator
        
        return coordinator
    }
    
    public class Coordinator: NSObject, NSTextFieldDelegate {
        var onChange: (String) -> Void
        var validator: TextValidator?
        var text: String
        
        init(initialText: String, onChange: @escaping (String) -> Void) {
            self.text = initialText
            self.onChange = onChange
        }
        
        public func controlTextDidChange(_ obj: Notification) {
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

public class CustomTextField: NSTextField {
    public override func becomeFirstResponder() -> Bool {
        drawsBackground = true
        
        return super.becomeFirstResponder()
    }
    
    public override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        
        drawsBackground = false
    }
}
