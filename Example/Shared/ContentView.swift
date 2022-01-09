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
                    .init(title: "可选时间"),
                    .init(title: "备忘"),
                    .init(title: "已完成")
                ])
                .usesAlternatingRowBackgroundColors()
                .onItemChange { row, col, item in
                    print("@@", item)
                }
            
            HStack {
                Button {
                    let newItem = Item(title: "6")
                    insertItem(newItem, after: selection2.first)
                    becomeFirstResponder(item: newItem, atColumn: 0)
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
        case 0: return TextCell(item.title).nsView
        case 1: return TextCell(item.score).nsView
        case 2: return DatePickerCell(date: item.date).nsView
        case 3: return DatePickerCell(date: item.optionalDate).nsView
        case 4: return ToggleCell(isOn: item[keyPath: \.finished]).nsView
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
    
    var title: String = "" {
        didSet {
            print("title", title)
        }
    }
    var date: Date = Date()
    var optionalDate: Date? {
        didSet {
            print("optionalDate", optionalDate)
        }
    }
    var finished = false {
        didSet {
            print("finished", finished)
        }
    }
    var score: Double = 0 {
        didSet {
            print("score", score)
        }
    }
    
    var id = UUID()
    
    var children: [Item]?
    
    init(title: String, children: [Item]? = nil) {
        self.title = title
        self.children = children
    }
}
