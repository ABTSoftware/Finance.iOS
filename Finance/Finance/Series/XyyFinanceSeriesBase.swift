//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// XyyFinanceSeriesBase.swift is part of SCICHART®, High Performance Scientific Charts
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

public class XyyFinanceSeriesBase<TRenderableSeries: SCIXyyRenderableSeriesBase, TDataSeries: ISCIXyyDataSeries>: FinanceSeriesBase<TRenderableSeries, TDataSeries> {
    
    private var xValues: DataSourceEditableProperty!
    private var yValues: DataSourceEditableProperty!
    private var y1Values: DataSourceEditableProperty!
    
    public init(
        name: String,
        xValues: DataSourceId,
        yValues: DataSourceId,
        y1Values: DataSourceId,
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
        
        self.yValues = DataSourceEditableProperty(
            name: FinanceString.yValues.name,
            parentName: name,
            initialValue: yValues
        ) { [weak self] _, value in
            self?.dependsOn(propertyId: FinanceString.yValues, value: value)
        }
        
        self.y1Values = DataSourceEditableProperty(
            name: FinanceString.y1Values.name,
            parentName: name,
            initialValue: y1Values
        ) { [weak self] _, value in
            self?.dependsOn(propertyId: FinanceString.y1Values, value: value)
        }
    }
    
    override func onDataDrasticallyChanged(dataManager: IDataManager) {
        let suspender = renderableSeries.suspendUpdates()
        defer {
            suspender.dispose()
        }
        
        dataSeries.clear()
        
        if let xValues = dataManager.getXValues(id: self.xValues.value),
           let yValues = dataManager.getYValues(id: self.yValues.value),
           let y1Values = dataManager.getYValues(id: self.y1Values.value) {
            dataSeries.append(x: xValues, y: yValues, y1: y1Values)
        }
    }
    
    public override func reset() {
        super.reset()
        
        xValues.reset()
        yValues.reset()
        y1Values.reset()
    }
}
