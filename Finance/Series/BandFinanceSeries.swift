//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// BandFinanceSeries.swift is part of SCICHART®, High Performance Scientific Charts
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

public class BandFinanceSeries: XyyFinanceSeriesBase<SCIFastBandRenderableSeries, SCIXyyDataSeries> {
    
    @EditableProperty
    public var strokeStyle: PenStyleEditableProperty!
    
    @EditableProperty
    public var strokeY1Style: PenStyleEditableProperty!
    
    @EditableProperty
    public var fillBrushStyle: BrushStyleEditableProperty!
    
    @EditableProperty
    public var fillY1BrushStyle: BrushStyleEditableProperty!
    
    public init(
        name: String,
        xValues: DataSourceId,
        yValues: DataSourceId,
        y1Values: DataSourceId,
        yAxisId: AxisId,
        yTooltipName: String? = nil,
        y1TooltipName: String? = nil
    ) {
        super.init(
            name: name,
            xValues: xValues,
            yValues: yValues,
            y1Values: y1Values,
            renderableSeries: SCIFastBandRenderableSeries(),
            dataSeries: SCIXyyDataSeries(xType: .date, yType: .double),
            yAxisId: yAxisId
        )
        
        renderableSeries.seriesInfoProvider = FinanceBandSeriesInfoProvider(yTooltipName: yTooltipName, y1TooltipName: y1TooltipName)
        
        self.strokeStyle = PenStyleEditableProperty(
            name: FinanceString.strokeStyle.name,
            parentName: name,
            initialValue: SCISolidPenStyle(color: Colors.defaultBlue, thickness: Colors.lightThickness)
        ) { [weak self] id, value in
            self?.renderableSeries.strokeStyle = value
            self?.onPropertyChanged(propertyId: id)
        }
        
        self.strokeY1Style = PenStyleEditableProperty(
            name: FinanceString.bandsY1StrokeStyle.name,
            parentName: name,
            initialValue: SCISolidPenStyle(color: Colors.defaultBlue, thickness: Colors.lightThickness)
        ) { [weak self] id, value in
            self?.renderableSeries.strokeY1Style = value
            self?.onPropertyChanged(propertyId: id)
        }
        
        self.fillBrushStyle = BrushStyleEditableProperty(
            name: FinanceString.fillStyle.name,
            parentName: name,
            initialValue: SCISolidBrushStyle(color: Colors.defaultBand)
        ) { [weak self] id, value in
            self?.renderableSeries.fillBrushStyle = value
            self?.onPropertyChanged(propertyId: id)
        }
        
        self.fillY1BrushStyle = BrushStyleEditableProperty(
            name: FinanceString.bandsY1FillStyle.name,
            parentName: name,
            initialValue: SCISolidBrushStyle(color: Colors.defaultBand)
        ) { [weak self] id, value in
            self?.renderableSeries.fillY1BrushStyle = value
            self?.onPropertyChanged(propertyId: id)
        }
    }
    
    public override func reset() {
        super.reset()
        
        strokeStyle.reset()
        strokeY1Style.reset()
        fillBrushStyle.reset()
        fillY1BrushStyle.reset()
    }
    
    open class FinanceBandSeriesInfoProvider: SCIDefaultBandSeriesInfoProvider {
        private let yTooltipName: String?
        private let y1TooltipName: String?
        
        public init(yTooltipName: String?, y1TooltipName: String?) {
            self.yTooltipName = yTooltipName
            self.y1TooltipName = y1TooltipName
            
            super.init(renderableSeriesType: SCIFastBandRenderableSeries.self)
        }
        
        open override func getSeriesTooltipInternal(seriesInfo: SCIBandSeriesInfo, modifierType: AnyClass) -> ISCISeriesTooltip {
            return FinanceBandSeriesTooltip(seriesInfo: seriesInfo, yTooltipName: yTooltipName, y1TooltipName: y1TooltipName)
        }
    }
    
    open class FinanceBandSeriesTooltip: SCISeriesTooltipBase<SCIBandSeriesInfo> {
        private let yTooltipName: String?
        private let y1TooltipName: String?
        private let fontStyle: SCIFontStyle
        
        public init(
            seriesInfo: SCIBandSeriesInfo,
            fontStyle: SCIFontStyle = Constants.defaultTooltipInfoFontStyle,
            yTooltipName: String?,
            y1TooltipName: String?
        ) {
            self.yTooltipName = yTooltipName
            self.y1TooltipName = y1TooltipName
            self.fontStyle = fontStyle
            
            super.init(seriesInfo: seriesInfo)

            self.numberOfLines = 1
        }
        
        open override func internalUpdate(with seriesInfo: SCIBandSeriesInfo) {
            let yValue = seriesInfo.formattedYValue.rawString
            let y1Value = seriesInfo.formattedY1Value.rawString
            let yColor = seriesInfo.renderableSeries.strokeStyle.color.withAlphaComponent(1)
            let y1Color = seriesInfo.renderableSeries.strokeY1Style.color.withAlphaComponent(1)
            
            let string = createString(yValue, y1Value)
            
            let attributedText = NSMutableAttributedString(string: string)
            
            attributedText.set(
                color: fontStyle.color,
                font: UIFont(descriptor: fontStyle.fontDescriptor, size: fontStyle.fontDescriptor.pointSize),
                textForAttribute: string
            )
            attributedText.set(color: yColor, textForAttribute: yValue)
            attributedText.set(color: y1Color, textForAttribute: y1Value)
            
            self.attributedText = attributedText
        }
        
        private func createString(_ yValue: String, _ y1Value: String) -> String {
            var string = ""
            if let y1TooltipName = y1TooltipName {
                string.append("\(y1TooltipName): ")
            }
            string.append("\(y1Value)")
            
            if let yTooltipName = yTooltipName {
                string.append(" \(yTooltipName):")
            }
            string.append(" \(yValue)")
            
            return string
        }
    }
}
