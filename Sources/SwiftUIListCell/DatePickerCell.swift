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
    @Binding private var date: Date?
    @State private var isEditing = false
    @State private var internalDate: Date?
    private var optionalDate: Bool
    
    private var formatter: (Date?) -> String
    
    public init(date: Binding<Date>, formatter: ((Date) -> String)? = nil) {
        self.optionalDate = false
        self._date = .init(get: {
            date.wrappedValue
        }, set: { newValue in
            date.wrappedValue = newValue!
        })
        self._internalDate = State(initialValue: date.wrappedValue)
        self.formatter = { date in
            formatter?(date!) ?? date!.formatted(in: .short, timeStyle: .short)
        }
    }
    
    public init(date: Binding<Date?>, formatter: ((Date?) -> String)? = nil) {
        self.optionalDate = true
        self._date = date
        self._internalDate = State(initialValue: date.wrappedValue)
        self.formatter = formatter ?? { (date: Date?) in
            date?.formatted(in: .short, timeStyle: .short) ?? " - "
        }
    }
    
    public var body: some View {
        HStack {
            TextCellView(text: .init(get: {
                formatter(internalDate)
            }, set: { _ in }),
                         canEdit: false, onDoubleClick: {
                isEditing = true
            })
              
            if optionalDate && internalDate != nil {
                Spacer()
                Button {
                    date = nil
                    internalDate = nil
                } label: {
                    Image(systemName: "minus.circle")
                }
                .buttonStyle(.plain)
            }
        }
            .popover(isPresented: $isEditing) {
                DatePicker("", selection: .init(get: {
                    internalDate ?? Date()
                }, set: { newValue in
                    internalDate = newValue
                }))
            }
            .onChange(of: isEditing) { isEditing in
                if !isEditing {
                    date = internalDate
                } else {
                    internalDate = Date()
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
