//
//  DatePickerCell.swift
//
//
//  Created by Kai on 2022/1/5.
//

import SwiftUI
import AppKit
import Combine

public struct DatePickerCell: CellWrappable {
    @Binding var date: Date
    
    public let doubleClickSubject = PassthroughSubject<Void, Never>()
    @State public var isEditing = false
    @State private var internalDate: Date
    
    public init(date: Binding<Date>) {
        self._date = date
        self._internalDate = State(initialValue: date.wrappedValue)
    }
    
    public var body: some View {
        if #available(macOS 12.0, *) {
            TextForCellView(text: .init(get: {
                date.formatted(date: .numeric, time: .standard)
            }, set: { _ in
                
            }), canEdit: false)
                .popover(isPresented: $isEditing) {
                    DatePicker("", selection: $internalDate)
                }
                .onReceive(doubleClickSubject) { _ in
                    isEditing = true
                }
                .onChange(of: isEditing) { isEditing in
                    if !isEditing {
                        date = internalDate
                    }
                }
        } else {
            // Fallback on earlier versions
        }
    }
}
