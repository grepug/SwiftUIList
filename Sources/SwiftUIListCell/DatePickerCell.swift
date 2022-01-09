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
    
    @State public var isEditing = false
    @State private var internalDate: Date
    
    @EnvironmentObject var cell: CellWrapper<Self>
    
    public init(date: Binding<Date>) {
        self._date = date
        self._internalDate = State(initialValue: date.wrappedValue)
    }
    
    public var body: some View {
        TextCellView(text: .constant(internalDate.formatted(in: .short, timeStyle: .short)),
                     canEdit: false, onDoubleClick: {
            isEditing = true
        })
            .foregroundColor(cell.textColor)
            .popover(isPresented: $isEditing) {
                DatePicker("", selection: $internalDate)
            }
            .onChange(of: isEditing) { isEditing in
                if !isEditing {
                    date = internalDate
                }
            }
    }
}

extension Date {
    func formatted(in type: DateFormatter.Style, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = type
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
}
