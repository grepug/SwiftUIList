//
//  ToggleCell.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import SwiftUI
import Combine

public struct ToggleCell: CellWrappable {
    @Binding private var isOn: Bool
    @State private var internalIsOn: Bool
    
    public init(isOn: Binding<Bool>) {
        self._isOn = isOn
        self._internalIsOn = State(initialValue: isOn.wrappedValue)
    }
    
    public var body: some View {
        HStack {
            Toggle("", isOn: $internalIsOn)
                .onChange(of: internalIsOn) { newValue in
                    isOn = internalIsOn
                }
            Spacer()
        }
    }
}
