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
    func _remove(item: Item, inParent parent: Item?, at index: Int, shouldDelete: Bool) {
        if let parent = parent {
            parent.children?.remove(at: index)
        } else {
            data.remove(at: index)
        }
    }
    
    func _insert(item: Item, into parent: Item?) -> ListItemInsertionInfo<Item> {
        let prevIds = parent?.children?.map(\.id) ?? data.map(\.id)
        
        if let parent = parent {
            let children = parent.children ?? []
            parent.children = children
            
            parent.children?.insert(item, at: children.endIndex)
        } else {
            data.insert(item, at: data.endIndex)
        }
        
        let ids = parent?.children?.map(\.id) ?? data.map(\.id)
        
        return .init(prevIds: prevIds, ids: ids)
    }
    
    func updateView() {}
    
    typealias Item = Example.Item
    
    @State var data: [Item] = [.init(title: "1xxxxxxxxxxxxx",
                                     children: [.init(title: "2",
                                                      children: [.init(title: "3")])]),
                               .init(title: "a")]
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
                        children: \.children,
                        operationSubject: Self.operations,
                        content: content)
                .contextMenu(menu: { info in
                    [.init(title: "添加子节点", action: {
                        let newItem = Item(title: "7")
                        insertItem(newItem, into: info.item)
                    }),
                     .init(title: "删除", action: {
                        removeItem(info.item, inParent: info.parent, at: info.childIndex)
                    }),
                     .init(title: "Move to",
                           children: Item.makeMoveToMenu(item: info.item,
                                                         items: items(),
                                                         children: \.children,
                                                         title: { $0?.title ?? "根节点" },
                                                         action: { targetItem in
                        moveItem(info.item, inParent: info.parent, at: info.childIndex, to: targetItem)
                    }))
                    ]
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
                .onAppear {
                    expand()
                }
            
            HStack {
                Button {
                    let newItem = Item(title: "6")
                    insertItem(newItem, into: nil)
                    becomeFirstResponder(item: newItem, atColumn: 1)
                } label: {
                    Image(systemName: "plus")
                }
                
                Button {
//                    selection2.forEach(removeItem)
                } label: {
                    Image(systemName: "minus")
                }
            }
            .padding()
        }
    }
    
    func content(row: Int, col: Int, item: Binding<Item>) -> NSView {
        switch col {
        case 0:
            return LabelCell(object: item.wrappedValue,
                             text: \.title,
                             systemImageName: "pencil",
                             systemImageColor: .red)
        case 1: return TextCell(item.score).nsView
        case 2: return DatePickerCell(date: item.date).nsView
        case 3: return DatePickerCell(date: item.optionalDate).nsView
        case 4: return ToggleCell(isOn: item[keyPath: \.finished]).nsView
        default: fatalError()
        }
    }
}

class Item: DataElement, MoveToMenuItem, ObservableObject {
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
