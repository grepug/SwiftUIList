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
    var onTextDidEndEditing: (() -> Void)?
    var onDoubleClick: (() -> Void)?
    
    public init(text: Binding<String>,
                validator: TextValidator? = nil,
                canEdit: Bool = true,
                onTextDidEndEditing: (() -> Void)? = nil,
                onDoubleClick: (() -> Void)? = nil) {
        self._text = text
        self.validator = validator
        self.canEdit = canEdit
        self.onTextDidEndEditing = onTextDidEndEditing
        self.onDoubleClick = onDoubleClick
    }
    
    public func makeNSView(context: Context) -> NSViewType {
        let textField = NSViewType()
        
        textField.stringValue = text
        textField.delegate = context.coordinator
        textField.isEditable = canEdit
        textField.isSelectable = canEdit
        textField.onDoubleClick = onDoubleClick
        
        return textField
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.stringValue = text
    }
    
    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(initialText: text, onTextDidEndEditing: {
            onTextDidEndEditing?()
        }, onChange: {
            text = $0
        })
        
        coordinator.validator = validator
        
        return coordinator
    }
    
    public class Coordinator: NSObject, NSTextFieldDelegate {
        var onChange: (String) -> Void
        var validator: TextValidator?
        var text: String
        var onTextDidEndEditing: () -> Void
        
        init(initialText: String,
             onTextDidEndEditing: @escaping () -> Void,
             onChange: @escaping (String) -> Void) {
            self.text = initialText
            self.onChange = onChange
            self.onTextDidEndEditing = onTextDidEndEditing
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
        
        public func controlTextDidEndEditing(_ obj: Notification) {
            onTextDidEndEditing()
        }
    }
}

public class CustomTextField: NSTextField {
    var onDoubleClick: (() -> Void)?
    
    init() {
        super.init(frame: .zero)

        isBezeled = false
        drawsBackground = false
        usesSingleLineMode = true
        cell?.wraps = false
        cell?.isScrollable = false
        maximumNumberOfLines = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            drawsBackground = true
            return true
        }
        
        return false
    }
    
    public override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        
        drawsBackground = false
    }
    
    public override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            onDoubleClick?()
        }
    }
    
    public override func rightMouseDown(with event: NSEvent) {
        nextResponder?.rightMouseDown(with: event)
    }
}
