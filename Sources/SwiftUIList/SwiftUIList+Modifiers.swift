//
//  File.swift
//  
//
//  Created by Kai on 2022/1/6.
//

import SwiftUI

public extension SwiftUIList {
    func onDoubleClick(action: @escaping (Int, Int, NSView) -> Void) -> Self {
        var mutableSelf = self
        mutableSelf.onDoubleClicked = action
        
        return mutableSelf
    }
    
    func contextMenu(menu: @escaping (Data.Element, Int, Int) -> [ListItemContextMenu]) -> Self {
        var mutableSelf = self
        mutableSelf.contextMenus = menu
        
        return mutableSelf
    }
    
    func columns(_ columns: [ListItemColumn]) -> Self {
        var mutableSelf = self
        mutableSelf.columns = columns
        
        return mutableSelf
    }
    
    func headerHidden() -> Self {
        var mutableSelf = self
        mutableSelf.hidingHeader = true
        
        return mutableSelf
    }
    
    func usesAlternatingRowBackgroundColors(_ isOn: Bool = true) -> Self {
        var mutableSelf = self
        mutableSelf.usingAlternatingRowBackgroundColors = isOn
        
        return mutableSelf
    }
    
    func drawsRowSeperators() -> Self {
        var mutableSelf = self
        mutableSelf.drawingRowSeperators = true
        
        return mutableSelf
    }
}
