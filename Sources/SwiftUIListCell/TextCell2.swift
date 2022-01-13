//
//  TextCell2.swift
//  
//
//  Created by Kai on 2022/1/13.
//

import AppKit
import Combine
import SwiftUI

public class LabelCell<Object: ObservableObject>: NSTableCellView, NSTextFieldDelegate {
    private var object: Object
    private var textKeyPath: ReferenceWritableKeyPath<Object, String>
    private lazy var textView = CustomTextField()
    private var cancellable: AnyCancellable?
    private var systemImageName: String?
    private var systemImageColor: NSColor? = nil
    private var iconImageView: NSImageView?
    
    public init(object: Object,
                text textKeyPath: ReferenceWritableKeyPath<Object, String>) {
        self.object = object
        self.textKeyPath = textKeyPath
        
        super.init(frame: .zero)
        
        setupSubscriber()
        setupView()
    }
    
    public init(object: Object,
                text textKeyPath: ReferenceWritableKeyPath<Object, String>,
                systemImageName: String,
                systemImageColor: Color? = nil) {
        self.object = object
        self.textKeyPath = textKeyPath
        self.systemImageName = systemImageName
        
        if let systemImageColor = systemImageColor {
            self.systemImageColor = NSColor(systemImageColor)
        }
        
        super.init(frame: .zero)
        
        setupSubscriber()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var backgroundStyle: NSView.BackgroundStyle {
        willSet {
            iconImageView?.image = iconImageView?.image?.tint(color: newValue == .emphasized ? .white : systemImageColor)
        }
    }
    
    func setupSubscriber() {
        cancellable = object.objectWillChange
            .map { _ in }
            .prepend(())
            .sink { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.textView.stringValue = self.object[keyPath: self.textKeyPath]
                }
            }
    }
    
    func setupView() {
        let containerView = NSStackView()
        
        if let systemImageName = systemImageName {
            let image = NSImage(systemSymbolName: systemImageName,
                            accessibilityDescription: nil)!
                .tint(color: systemImageColor)
            iconImageView = NSImageView(image: image)
            containerView.addArrangedSubview(iconImageView!)
        }
        
        containerView.addArrangedSubview(textView)
        containerView.orientation = .horizontal
        
        addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    public func controlTextDidEndEditing(_ obj: Notification) {
        let textField = obj.object as! CustomTextField
        
        object[keyPath: textKeyPath] = textField.stringValue
    }
}

extension NSImage {
    func tint(color: NSColor?) -> NSImage {
        guard let color = color else {
            return self
        }
        
        return NSImage(size: size, flipped: false) { (rect) -> Bool in
            color.set()
            rect.fill()
            self.draw(in: rect, from: NSRect(origin: .zero, size: self.size), operation: .destinationIn, fraction: 1.0)
            return true
        }
    }
}
