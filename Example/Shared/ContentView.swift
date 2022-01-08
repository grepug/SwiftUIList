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
    typealias Item = Example.Item
    
    @State var data: [Item] = [.init(title: "1",
                                     children: [.init(title: "2",
                                                      children: [.init(title: "3")])])]
    @State var selection: Item?
    @State var selection2 = Set<Item>()
    
    let operations = PassthroughSubject<ListOperation<Item>,Never>()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SwiftUIList($data,
                        selection: $selection2,
                        operationSubject: operations,
                        content: content)
                .contextMenu(menu: { row, col, item in
                    [.init(title: "a") {
                    }, .init(title: "b")]
                })
                .columns([
                    .init(title: "值"),
                    .init(title: "时间"),
                    .init(title: "备忘"),
                    .init(title: "已完成", shouldReloadOnUpdate: true)
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
            
            HStack {
                Button {
                    let newItem = Item(title: "6")
                    operations.send(.insert(newItem, after: selection2.first))
                } label: {
                    Image(systemName: "plus")
                }
                
                Button {
                    if let item = selection2.first {
                        operations.send(.remove(item))
                    }
                } label: {
                    Image(systemName: "minus")
                }
            }
            .padding()
        }
    }
    
    func content(row: Int, col: Int, item: Binding<Item>) -> NSView {
        switch col {
        case 0: return TextForCell(item.title).nsView
        case 1: return TextForCell(item: item, double: \.score, onChange: ()).nsView
//        case 2: return DatePickerCell(date: item.date).nsView
        case 2: return TextForCell("").nsView
        case 3: return ToggleCell(isOn: item[keyPath: \.finished]).nsView
        default: fatalError()
        }
    }
}

class Item: ListItemKind {
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var title: String = ""
    var date: Date = Date()
    var finished = false {
        didSet {
            print("score", finished)
        }
    }
    var score: Double = 0
    
    var id = UUID()
    
    var children: [Item]?
    
    init(title: String, children: [Item]? = nil) {
        self.title = title
        self.children = children
    }
}
