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
            formatter?(date!) ?? Self.defaultDateFormatter(date: date)
        }
    }
    
    public init(date: Binding<Date?>, formatter: ((Date?) -> String)? = nil) {
        self.optionalDate = true
        self._date = date
        self._internalDate = State(initialValue: date.wrappedValue)
        self.formatter = { (date: Date?) in
            formatter?(date) ?? Self.defaultDateFormatter(date: date)
        }
    }
    
    public init<Content: View>(date: Binding<Date?>,
                               formatter: ((Date) -> String)? = nil,
                               emptyView: () -> Content) {
        self.optionalDate = true
        self._date = date
        self._internalDate = State(initialValue: date.wrappedValue)
        self.formatter = { (date: Date?) in
            if let date = date, let formatter = formatter {
                return formatter(date)
            }
            
            return Self.defaultDateFormatter(date: date)
        }
    }
    
    public var body: some View {
        HStack {
            TextCellView(text: .constant(formatter(internalDate)),
                         canEdit: false,
                         onDoubleClick: {
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
                    if internalDate == nil {
                        internalDate = Date()
                    }
                }
            }
    }
}

extension DatePickerCell {
    static func defaultDateFormatter(date: Date?) -> String {
        date?.formatted(in: .short, timeStyle: .short) ?? " - "
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
