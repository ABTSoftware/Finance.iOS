//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// OhlcFinanceSeriesBase.swift is part of SCICHART®, High Performance Scientific Charts
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
import SciChart.Protected.SCISeriesInfoProviderBase
import SciChart.Protected.SCISeriesTooltipBase

public class OhlcFinanceSeriesBase<TRenderableSeries: SCIOhlcRenderableSeriesBase, TDataSeries: ISCIOhlcDataSeries>: FinanceSeriesBase<TRenderableSeries, TDataSeries> {
    
    private var xValues: DataSourceEditableProperty!
    private var open: DataSourceEditableProperty!
    private var high: DataSourceEditableProperty!
    private var low: DataSourceEditableProperty!
    private var close: DataSourceEditableProperty!
    
    public init(
        name: String,
        xValues: DataSourceId,
        open: DataSourceId,
        high: DataSourceId,
        low: DataSourceId,
        close: DataSourceId,
        renderableSeries: TRenderableSeries,
        dataSeries: TDataSeries,
        yAxisId: AxisId
    ) {
        super.init(name: name, renderableSeries: renderableSeries, dataSeries: dataSeries, yAxisId: yAxisId)
        
        self.xValues = DataSourceEditableProperty(
            name: FinanceString.xValues.name,
            parentName: name,
            initialValue: xValues
        ) { [weak self] _, value in
            self?.dependsOn(propertyId: FinanceString.xValues, value: value)
        }
        
        self.open = DataSourceEditableProperty(
            name: FinanceString.openValues.name,
            parentName: name,
            initialValue: open
        ) { [weak self] _, value in
            self?.dependsOn(propertyId: FinanceString.openValues, value: value)
        }
        
        self.high = DataSourceEditableProperty(
            name: FinanceString.highValues.name,
            parentName: name,
            initialValue: high
        ) { [weak self] _, value in
            self?.dependsOn(propertyId: FinanceString.highValues, value: value)
        }
        
        self.low = DataSourceEditableProperty(
            name: FinanceString.lowValues.name,
            parentName: name,
            initialValue: low
        ) { [weak self] _, value in
            self?.dependsOn(propertyId: FinanceString.lowValues, value: value)
        }
        
        self.close = DataSourceEditableProperty(
            name: FinanceString.closeValues.name,
            parentName: name,
            initialValue: close
        ) { [weak self] _, value in
            self?.dependsOn(propertyId: FinanceString.closeValues, value: value)
        }
    }
    
    override func onDataDrasticallyChanged(dataManager: IDataManager) {
        let suspender = renderableSeries.suspendUpdates()
        defer {
            suspender.dispose()
        }
        
        dataSeries.clear()
        
        if let xValues = dataManager.getXValues(id: self.xValues.value),
            let openValues = dataManager.getYValues(id: self.open.value),
            let highValues = dataManager.getYValues(id: self.high.value),
            let lowValues = dataManager.getYValues(id: self.low.value),
            let closeValues = dataManager.getYValues(id: self.close.value) {
            dataSeries.append(x: xValues, open: openValues, high: highValues, low: lowValues, close: closeValues)
        }
    }
    
    public override func reset() {
        super.reset()
        
        xValues.reset()
        open.reset()
        high.reset()
        low.reset()
        close.reset()
    }
}
