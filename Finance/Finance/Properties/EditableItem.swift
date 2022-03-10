//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// EditableItem.swift is part of SCICHART®, High Performance Scientific Charts
// For full terms and conditions of the license, see http://www.scichart.com/scichart-eula/
//
// This source code is protected by international copyright law. Unauthorized
// reproduction, reverse-engineering, or distribution of all or any portion of
// this source code is strictly prohibited.
//
// This source code contains confidential and proprietary trade secrets of
// SciChart Ltd., and should at no time be copied, transferred, sold,
// distributed or made available without express written permission.
//******************************************************************************

import Foundation
import SciChart

@objc public protocol IEditable {
    var viewType: ViewType { get }
    
    var name: String { get }
    
    func reset()
    
    func isValidEditableForSettings(_ editable: IEditable) -> Bool
}

open class EditableItem: IEditable {
    public let viewType: ViewType
    open var name: String {
        fatalError("Must be implemented in subclasses")
    }
    
    public init(viewType: ViewType) {
        self.viewType = viewType
    }
    
    open func reset() {
        fatalError("Must be implemented in subclasses")
    }
    
    open func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return true
    }
}
