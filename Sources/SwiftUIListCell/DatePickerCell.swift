//
//  DatePickerCell.swift
//
//
//  Created by Kai on 2022/1/5.
//

import AppKit

public class DatePickerCell: NSTableCellView {
    public init(date: Date) {
        let field = NSDatePicker()
        field.datePickerStyle = .textField
        field.isBezeled = false
        field.cell?.isScrollable = false
//        field.isEditable = false
//        field.isSelectable = false
//        field.isBezeled = false
//        field.drawsBackground = false
//        field.usesSingleLineMode = false
//        field.cell?.wraps = true
//        field.cell?.isScrollable = false

        super.init(frame: .zero)

        addSubview(field)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: leadingAnchor),
            field.trailingAnchor.constraint(equalTo: trailingAnchor),
            field.topAnchor.constraint(equalTo: topAnchor),
            field.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
