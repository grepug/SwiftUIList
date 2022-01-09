//
//  NodeCell.swift
//  Example (macOS)
//
//  Created by Kai on 2022/1/9.
//

import SwiftUI
import SwiftUIListCell
import Combine
import SwiftUIList

struct NodeCell: CellWrappable {
    let doubleClickSubject = PassthroughSubject<Void, Never>()
    
    @Binding var text: String
    @Binding var emoji: String
    var trailingNumber: Int
    
    @State private var showing = false
    @State private var internalSelection: String
    @EnvironmentObject private var cell: CellWrapper<Self>
    
    init(text: Binding<String>,
         emoji: Binding<String>,
         trailingNumber: Int = 0) {
        self._text = text
        self._emoji = emoji
        self._internalSelection = State(initialValue: emoji.wrappedValue)
        self.trailingNumber = trailingNumber
    }
    
    var body: some View {
        HStack {
            HStack {
                Text(emoji)
                    .modifier(EmojiPickerPopover(isPresented: $showing,
                                                 selection: $internalSelection))
                    .onChange(of: internalSelection) { newValue in
                        emoji = newValue
                    }
                TextCellView(text: $text)
            }
            Spacer()
            Text("\(trailingNumber)")
                .foregroundColor(cell.textColor)
        }
    }
}

//protocol ListItemMovable: ListItemKind {
//    var title: String { get set }
//}
//
//extension ListItemMovable {
//    func moveToList(children: [Self]? = nil) -> [(Self, Int)] {
//        var res = [(Self, Int)]()
//
//
//    }
//
//    static private func isChildrenOf(item: Self, in outlineView: NSOutlineView) -> Bool {
//
//    }
//}
