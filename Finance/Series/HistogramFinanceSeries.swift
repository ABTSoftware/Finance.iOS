//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// HistogramFinanceSeries.swift is part of SCICHART®, High Performance Scientific Charts
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

public class HistogramFinanceSeries: XyFinanceSeriesBase<SCIFastColumnRenderableSeries, SCIXyDataSeries> {
    
    @EditableProperty
    public var fillUpBrushStyle: BrushStyleEditableProperty!
    
    @EditableProperty
    public var fillDownBrushStyle: BrushStyleEditableProperty!
    
    public init(
        name: String,
        xValues: DataSourceId,
        yValues: DataSourceId,
        yAxisId: AxisId,
        yTooltipName: String? = nil
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
        
        self.fillUpBrushStyle = BrushStyleEditableProperty(
            name: FinanceString.histogramFillUpStyle.name,
            parentName: name,
            initialValue: SCISolidBrushStyle(color: Colors.defaultFillUp)
        ) { [weak self] id, _ in
            self?.onPropertyChanged(propertyId: id)
        }
        
        self.fillDownBrushStyle = BrushStyleEditableProperty(
            name: FinanceString.histogramFillDownStyle.name,
            parentName: name,
            initialValue: SCISolidBrushStyle(color: Colors.defaultFillDown)
        ) { [weak self] id, _ in
            self?.onPropertyChanged(propertyId: id)
        }
        
        renderableSeries.paletteProvider = FinanceSeriesPaletteProvider(inputs: [yValues]) { [weak self] map, index in
            guard let self = self,
                  let yValue = map[yValues]?.getValueAt(index)
            else {
                return Colors.defaultLegendValueColor
            }
            
            let opacity = CGFloat(self.opacity.value)
            return yValue < 0.0 ?
                self.fillDownBrushStyle.value.color.withAlphaComponent(opacity) :
                self.fillUpBrushStyle.value.color.withAlphaComponent(opacity)
        }
    }
    
    public override func reset() {
        super.reset()
        
        fillUpBrushStyle.reset()
        fillDownBrushStyle.reset()
    }
}
