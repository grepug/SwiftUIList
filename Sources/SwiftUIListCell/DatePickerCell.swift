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
    
    public init(date: Binding<Date>) {
        self._date = date
    }
    
    public var body: some View {
        if #available(macOS 12.0, *) {
            TextForCell(date.formatted(date: .numeric, time: .shortened))
                .popover(isPresented: $isEditing) {
                    DatePicker("", selection: $date)
                }
                .onReceive(doubleClickSubject) { _ in
                    isEditing = true
                }
        } else {
            // Fallback on earlier versions
        }
    }
}
