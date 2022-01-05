//
//  ContentView.swift
//  Shared
//
//  Created by Kai on 2022/1/5.
//

import SwiftUI
import SwiftUIList
import SwiftUIListCell
import Combine

struct ContentView: View {
    @State var data: [Item] = [.init(title: "1"), .init(title: "2"), .init(title: "3")]
    @State var selection: Item? = Item(title: "2")
    
    var body: some View {
        SwiftUIList(data,
                    selection: $selection,
                    content: content)
        .contextMenu(menu: { row, col, item in
            [.init(title: "a") {
            }, .init(title: "b")]
        })
        .columns([
            .init(title: "值"),
            .init(title: "时间"),
            .init(title: "备忘")
        ])
        .onDoubleClick { row, col, view in
            switch col {
            case 0:
                if let textField = view.subviews(ofType: NSTextField.self).first {
                    textField.isEditable = true
                }
            case 2:
                if let hostingView = view.subviews(ofType: NSHostingView<DatePickerCell2>.self).first {
                    hostingView.rootView.doubleClickSubject.send()
                }
            default: break
            }
        }
    }
    
    func content(row: Int, col: Int, item: Item) -> NSView {
        switch col {
        case 0: return TextCell(text: item.title)
        case 1: return DatePickerCell(date: item.date)
        case 2:
            let view = DatePickerCell2(date: .constant(item.date),
                                       isSelected: selection?.id == item.id,
                                       isEditing: false)
            let nsView = NSHostingView(rootView: view)
            return nsView
        default: fatalError()
        }
    }
}

struct Item: Identifiable {
    var title: String
    var date: Date = Date()
    
    var id: String { title }
}

struct DatePickerCell2: View {
    @Binding var date: Date
    var isSelected: Bool
    @State var isEditing = false
    
    let doubleClickSubject = PassthroughSubject<Void, Never>()
    
    var body: some View {
        Text2(text: date.formatted())
            .popover(isPresented: $isEditing) {
                DatePicker("", selection: $date)
            }
            .onReceive(doubleClickSubject) { _ in
                isEditing = true
            }
    }
}

struct Text2: NSViewRepresentable {
    typealias NSViewType = NSTextField
    
    var text: String
    
    func makeNSView(context: Context) -> NSTextField {
        .init(string: text)
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text
        nsView.isEditable = false
        nsView.isSelectable = false
        nsView.isBezeled = false
        nsView.drawsBackground = false
        nsView.usesSingleLineMode = false
        nsView.cell?.wraps = true
        nsView.cell?.isScrollable = false
    }
}
