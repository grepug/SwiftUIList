//
//  ToggleCell.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import SwiftUI
import Combine

public struct ToggleCell: CellWrappable {
    @Binding var isOn: Bool
    
    public let doubleClickSubject = PassthroughSubject<Void, Never>()
    
    public init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }
    
    public init<Item>(item: Binding<Item>, isOn: ReferenceWritableKeyPath<Item, Bool>) {
        self._isOn = .init(get: {
            let value = item.wrappedValue[keyPath: isOn]
            print("value", value)
            return value
        }, set: { newValue in
            item.wrappedValue[keyPath: isOn] = newValue
        })
    }
    
    public var body: some View {
        Toggle("", isOn: $isOn)
    }
}
