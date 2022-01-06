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
    @State var selection: Item?
    
    var body: some View {
        SwiftUIList($data,
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
        .usesAlternatingRowBackgroundColors()
        .onDoubleClick { row, col, view in
            switch col {
            case 0: view.cell(of: TextForCell.self)?.doubleClickSubject.send()
            case 1: view.cell(of: TextForCell.self)?.doubleClickSubject.send()
            case 2: view.cell(of: DatePickerCell.self)?.doubleClickSubject.send()
            default: break
            }
        }
    }
    
    func content(row: Int, col: Int, item: Binding<Item>) -> NSView {
        switch col {
        case 0: return TextForCell(item.title, textValidator: .int).nsView
        case 1: return TextForCell(item.score).nsView
        case 2: return DatePickerCell(date: item.date).nsView
        default: fatalError()
        }
    }
}

struct Item: Identifiable {
    var title: String
    var date: Date = Date()
    var score = 0
    
    var id: String { title }
}
