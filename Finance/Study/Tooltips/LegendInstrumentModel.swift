//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// LegendInstrumentInfo.swift is part of the SCICHART® SciTraider App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTraider App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import Foundation

public struct LegendInstrumentModel {
    let name: String
    let lastPrice: Double
    let priceChange: Double
    let priceChangePercent: Double
    let priceFormat: String
    
    public init(
        name: String,
        lastPrice: Double,
        priceChange: Double,
        priceChangePercent: Double,
        priceFormat: String
    ) {
        self.name = name
        self.lastPrice = lastPrice
        self.priceChange = priceChange
        self.priceChangePercent = priceChangePercent
        self.priceFormat = priceFormat
    }
}
