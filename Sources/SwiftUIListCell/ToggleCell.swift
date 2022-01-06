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
    
    public var body: some View {
        Toggle("", isOn: $isOn)
    }
}
