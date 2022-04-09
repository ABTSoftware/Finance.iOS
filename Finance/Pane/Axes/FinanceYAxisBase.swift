//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FinanceYAxisBase.swift is part of SCICHART®, High Performance Scientific Charts
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
import SwiftUI

open class FinanceYAxisBase<TAxis: ISCIAxis>: AttachableBase, IFinanceAxis {
    public let viewType = ViewType.yAxis
    
    @EditableProperty
    public var textFormatting: StringEditableProperty!
    
    @EditableProperty
    public var cursorTextFormatting: StringEditableProperty!
    
    open var axisId: AxisId {
        willSet {
            yAxis?.axisId = newValue.description
        }
    }
    private var yAxis: TAxis?
    
    public private(set) var name: String
    
    public init(
        name: String,
        axisId: AxisId,
        textFormatting: String,
        cursorTextFormatting: String
    ) {
        self.name = name
        self.axisId = axisId
        
        super.init()
        
        self.textFormatting = StringEditableProperty(
            name: FinanceString.textFormattingAxis.name,
            parentName: name,
            initialValue: textFormatting,
            listener: { [weak self] _, textFormatting in
                self?.yAxis?.textFormatting = textFormatting
            })
        
        self.cursorTextFormatting = StringEditableProperty(
            name: FinanceString.cursorTextFormattingAxis.name,
            parentName: name,
            initialValue: cursorTextFormatting,
            listener: { [weak self] _, cursorTextFormatting in
                self?.yAxis?.cursorTextFormatting = cursorTextFormatting
            })
    }
    
    open func placeInto(pane: IPane) {
        let chart = pane.chart
        
        let yAxis = createAxis()
        initAxis(axis: yAxis)
        
        let thisAxisId = axisId
        if let duplicateAxis = chart.yAxes.firstOrDefault({
            if let axis = $0 as? ISCIAxis {
                return FinanceYAxisBase.shouldShareVisibleRange(thisId: thisAxisId, thatId: AxisId.fromString(axisId: axis.axisId))
            } else {
                return false
            }
        }) {
            yAxis.visibleRange = duplicateAxis.visibleRange
        }
        
        chart.yAxes.add(yAxis)
        self.yAxis = yAxis
    }
    
    open func removeFrom(pane: IPane) {
        let chart = pane.chart
        
        if let yAxis = yAxis {
            yAxis.visibleRange = SCIDoubleRange()
            chart.yAxes.remove(yAxis)
        }
        
        yAxis = nil
    }
    
    open func createAxis() -> TAxis {
        fatalError("Must be implemented in subclasses")
    }
    
    open func initAxis(axis: TAxis) {
        axis.axisId = axisId.description
        axis.axisInfoProvider = YAxisSeriesInfoProvider()
        axis.textFormatting = textFormatting.value
        axis.cursorTextFormatting = cursorTextFormatting.value
    }
    
    public func savePropertyStateTo(state: EditablePropertyState) {
        state.savePropertyValues(editable: self)
    }
    
    public func restorePropertyStateFrom(state: EditablePropertyState) {
        state.tryRestorePropertyValues(editable: self)
    }
    
    public static func shouldShareVisibleRange(thisId: AxisId, thatId: AxisId) -> Bool {
        // if axis is placed inside same pane and have same name it should share same VisibleRange
                // e.g. if MA is placed within same chart as price series
        return thisId.axisName == thatId.axisName && thisId.pane == thatId.pane
    }
    
    public static func selectAxesWithNonSharedRange(yAxes: SCIAxisCollection) -> SCIAxisCollection {
        // group yAxes by pane and axisName ( excluding study ) to get list of yAxes with shared VisibleRange
        // and select only one axis from each group to prevent bugs with modifiers which change VisibleRange
        let axes = yAxes.toArray().groupBy { axis -> String in
            let axisId = AxisId.fromString(axisId: axis.axisId)
            
            return "\(axisId.pane.id)\(axisId.axisName)"
        }.values.compactMap { $0.first }
        
        return SCIAxisCollection(collection: axes)
    }
    
    open func reset() {}
    
    open func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return true
    }
}
