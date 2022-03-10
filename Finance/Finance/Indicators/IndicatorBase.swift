//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// IndicatorBase.swift is part of SCICHART®, High Performance Scientific Charts
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

import SciChart
import SwiftCCTALib

public class IndicatorBase: DependableBase, IIndicator {
    public var viewType: ViewType { .indicator }
    
    public let name: String
    
    public init(name: String) {
        self.name = name
        
        super.init()
    }
    
    public func savePropertyStateTo(state: EditablePropertyState) {
        state.savePropertyValues(editable: self)
    }
    
    public func restorePropertyStateFrom(state: EditablePropertyState) {
        state.tryRestorePropertyValues(editable: self)
    }
    
    public func reset() {
        fatalError("Must be implemented in subclasses")
    }
    
    open func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return true
    }
    
    public func shouldSkipCalculation(lookback: TA_Integer, startIndex: TA_Integer, endIndex: TA_Integer) -> Bool {
        if lookback < 0 { return true }
        return max(lookback, startIndex) > endIndex
    }
}
