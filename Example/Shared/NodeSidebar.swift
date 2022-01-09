//
//  NodeSidebar.swift
//  Example (macOS)
//
//  Created by Kai on 2022/1/9.
//

import SwiftUI
import SwiftUIList
import SwiftUIListCell

struct NodeSidebarContainer: View {
    var body: some View {
        NavigationView {
            Sidebar()
            Color.clear
        }
    }
}

struct Sidebar: View {
    @State var data: [Node] = [
        .init("a", children: [
            .init("aa", children: [
                .init("aaa")
            ])
        ])
    ]
    @State var selection: Node?
    
    var body: some View {
        VStack {
            SwiftUIList($data, selection: $selection, content: { row, col, $item in
                NodeCell(text: $item.title, emoji: $item.emoji).cellWrappedView
            })
                .contextMenu { item, row, col in
                    [
                        .init(title: "Delete"),
                        .init(title: "Move to")
                    ]
                }
        }
    }
}

class Node: ListItemKind {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    var title: String
    var emoji: String = "❓"
    var children: [Node]?
    
    init(_ title: String, children: [Node]? = nil) {
        self.title = title
        self.children = children
    }
}