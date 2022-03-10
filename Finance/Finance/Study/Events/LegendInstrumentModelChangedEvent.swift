//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// LegendInstrumentModelChangedEvent.swift is part of the SCICHART® SciTraider App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTraider App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import Foundation

public class LegendInstrumentModelChangedEvent: IFinanceChartEvent {
    let model: LegendInstrumentModel?
    
    public init(_ model: LegendInstrumentModel?) {
        self.model = model
    }
}
