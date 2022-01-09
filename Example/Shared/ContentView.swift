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

struct ContentView: View, ListViewOperable {
    func updateView() {
        
    }
    
    typealias Item = Example.Item
    
    @State var data: [Item] = [.init(title: "1",
                                     children: [.init(title: "2",
                                                      children: [.init(title: "3")])])]
    @State var selection: Item?
    @State var selection2 = Set<Item>()
    
    static let operations = OperationSubject<Item>()
    func items() -> [Item] {
        data
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SwiftUIList($data,
                        selection: $selection2,
                        operationSubject: Self.operations,
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
                    case 0: view.cell(of: TextCell.self)?.doubleClickSubject.send()
                    case 1: view.cell(of: TextCell.self)?.doubleClickSubject.send()
                    case 2: view.cell(of: DatePickerCell.self)?.doubleClickSubject.send()
                    default: break
                    }
                }
                .onItemChange { row, col, item in
                    print("@@", item)
                }
            
            HStack {
                Button {
                    let newItem = Item(title: "6")
                    insertItem(newItem, after: selection2.first)
                } label: {
                    Image(systemName: "plus")
                }
                
                Button {
                    if let item = selection2.first {
                        removeItem(item)
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
        case 0: return TextCell(item.title).cellWrappedView
        case 1: return TextCell(item: item, double: \.score, onChange: ()).cellWrappedView
        case 2: return DatePickerCell(date: item.date).nsView
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
