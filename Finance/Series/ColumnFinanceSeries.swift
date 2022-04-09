//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// ColumnFinanceSeries.swift is part of SCICHART®, High Performance Scientific Charts
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

public class ColumnFinanceSeries: XyFinanceSeriesBase<SCIFastColumnRenderableSeries, SCIXyDataSeries> {
    
    @EditableProperty
    public var strokeStyle: PenStyleEditableProperty!
    
    @EditableProperty
    public var fillStyle: BrushStyleEditableProperty!
    
    @EditableProperty
    public var dataPointWidth: DoubleEditableProperty!
    
    public init(
        name: String,
        xValues: DataSourceId,
        yValues: DataSourceId,
        yAxisId: AxisId,
        yTooltipName: String?
    ) {
        super.init(
            name: name,
            xValues: xValues,
            yValues: yValues,
            renderableSeries: SCIFastColumnRenderableSeries(),
            dataSeries: SCIXyDataSeries(xType: .date, yType: .double),
            yAxisId: yAxisId,
            yTooltipName: yTooltipName
        )
        
        self.strokeStyle = PenStyleEditableProperty(
            name: FinanceString.strokeStyle.name,
            parentName: name,
            initialValue: SCISolidPenStyle(color: Colors.defaultGreen, thickness: Colors.lightThickness)
        ) { [weak self] id, value in
            self?.renderableSeries.strokeStyle = value
            self?.onPropertyChanged(propertyId: id)
        }
        
        self.fillStyle = BrushStyleEditableProperty(
            name: FinanceString.fillStyle.name,
            parentName: name,
            initialValue: SCISolidBrushStyle(color: Colors.defaultGreen)
        ) { [weak self] id, value in
            self?.renderableSeries.fillBrushStyle = value
            self?.onPropertyChanged(propertyId: id)
        }
        
        self.dataPointWidth = DataPointWidthEditableProperty(
            name: FinanceString.dataPointWidth.name,
            parentName: name,
            initialValue: Colors.defaultCandleStickDataPointWidth
        ) { [weak self] id, value in
            self?.renderableSeries.dataPointWidth = value
            self?.onPropertyChanged(propertyId: id)
        }
    }
    
    public override func reset() {
        super.reset()
        
        strokeStyle.reset()
        fillStyle.reset()
    }
}
