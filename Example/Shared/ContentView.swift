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
    @State var data: [Item] = [.init(title: "1",
                                     children: [.init(title: "a",
                                                      children: [.init(title: "b")])])]
    @State var selection: Item?
    
    @State var selection2 = Set<Item>()
    
    var body: some View {
        SwiftUIList($data,
                    selection: $selection2,
                    content: content)
        .contextMenu(menu: { row, col, item in
            [.init(title: "a") {
            }, .init(title: "b")]
        })
        .columns([
            .init(title: "值"),
            .init(title: "时间"),
            .init(title: "备忘"),
            .init(title: "已完成")
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
        case 1: return TextForCell(.constant(0)).nsView
        case 2: return DatePickerCell(date: .constant(.init())).nsView
        case 3: return ToggleCell(isOn: item.finished).nsView
        default: fatalError()
        }
    }
}

final class Item: ListItemKind {
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var title: String = ""
//    var date: Date = Date()
//    var score = 0
    var finished = false
    
    var id: String { title }
    
    var children: [Item]?
    
    init(title: String, children: [Item]? = nil) {
        self.title = title
        self.children = children
    }
}
