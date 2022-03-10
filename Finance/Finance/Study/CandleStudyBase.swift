//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// CandleStudyBase.swift is part of SCICHART®, High Performance Scientific Charts
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

open class CandleStudyBase: StudyBase {
    
    public let yAxisId: AxisId
    
    @EditableProperty
    public var yAxis: FinanceNumericYAxis!
    
    public init(
        id: StudyId,
        pane: PaneId,
        yAxisName: String = FinanceString.defaultYAxis.name,
        yAxisId: String = DEFAULT_AXIS_ID
    ) {
        let yAxisId = AxisId(pane: pane, study: id, axisName: yAxisId)
        self.yAxisId = yAxisId

        super.init(id: id, pane: pane)
        
        self.yAxis = FinanceNumericYAxis(name: yAxisName, axisId: yAxisId)
        financeYAxes.add(self.yAxis)
    }
    
    open override func reset() {
        yAxis.reset()
    }
}
