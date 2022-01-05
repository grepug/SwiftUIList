//
//  ContentView.swift
//  Shared
//
//  Created by Kai on 2022/1/5.
//

import SwiftUI
import SwiftUIList

struct ContentView: View {
    @State var data: [Item] = [.init(title: "1"), .init(title: "2"), .init(title: "3")]
    @State var selection: Item?
    
    var body: some View {
        SwiftUIList(data,
                    selection: $selection) { item in
            let text = NSTextField(string: item.title)
            text.backgroundColor = .red
            print("text", text)
            
            return text
        }
    }
}

struct Item: Identifiable {
    var id = UUID()
    var title: String
}
