//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FinanceDateXAxis.swift is part of SCICHART®, High Performance Scientific Charts
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

public class FinanceDateXAxis: SCIDateAxis {
    init() {
        super.init(defaultNonZeroRange: SCIDateRange(), axisModifierSurface: SCIAxisModifierSurface())
        
        labelProvider = SCIDateLabelProvider(labelFormatter: SCICalendarDateLabelFormatter(locale: .current, timeZone: .init(identifier: "UTC") ?? .current))
        
        // need to set empty string to use CalendarDateLabelFormatter
        textFormattingProperty.setWeakValue("")
        cursorTextFormattingProperty.setWeakValue("")
    }
    
    var onSizeChange: ((CGSize) -> Void)?
    public override func onSizeChanged(_ size: CGSize, oldSize: CGSize) {
        super.onSizeChanged(size, oldSize: oldSize)
        
        onSizeChange?(size)
    }
}
