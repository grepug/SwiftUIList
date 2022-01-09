//
//  File.swift
//  
//
//  Created by Kai on 2022/1/8.
//

import AppKit
import SwiftUI
import Combine

class CellWrapper<Content: View>: NSTableCellView, ObservableObject {
    @Published var isSelected: Bool = false
    let doubleClickedSubject = PassthroughSubject<Void, Never>()
    
    init(rootView: Content) {
        super.init(frame: .zero)
        
        let view = rootView.environmentObject(self)
        let hostingView = NSHostingView(rootView: view)
        
        addSubview(hostingView)
        
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        willSet {
            isSelected = newValue == .emphasized
        }
    }
}