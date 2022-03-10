//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2022. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FinanceChartView.swift is part of the SCICHART® FinanceLibDemo App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® FinanceLibDemo App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SwiftUI
import Finance

struct FinanceChartView: UIViewRepresentable {
    func makeUIView(context: Context) -> SciFinanceChart {
        let chart = SciFinanceChart()
        
        let candleDataProvider = DefaultCandleDataProvider()
        chart.candleDataProvider = candleDataProvider
        
        fillDataProvider(candleDataProvider, with: DataManager.getCandles())
        
        chart.studies.add(PriceSeriesStudy())
        chart.studies.add(RSIStudy(pane: PaneId.uniqueId(name: "RSI")))
        
        chart.isCursorEnabled = true
        
        return chart
    }
    
    func updateUIView(_ uiView: SciFinanceChart, context: Context) {}
    
    private func fillDataProvider(_ dataProvider: ICandleDataProvider, with candles: [Candlestick]) {
        for candlestick in candles {
            dataProvider.xValues.addTime(candlestick.openTime)
            dataProvider.openValues.add(candlestick.open)
            dataProvider.highValues.add(candlestick.high)
            dataProvider.lowValues.add(candlestick.low)
            dataProvider.closeValues.add(candlestick.close)
            dataProvider.volumeValues.add(candlestick.volume)
        }
    }
}
