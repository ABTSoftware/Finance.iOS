//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// CandlestickFinanceSeries.swift is part of SCICHART®, High Performance Scientific Charts
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

public class CandlestickFinanceSeries: OhlcFinanceSeriesBase<SCIFastCandlestickRenderableSeries, SCIOhlcDataSeries> {
    
    @EditableProperty
    public var strokeUpStyle: PenStyleEditableProperty!
    
    @EditableProperty
    public var strokeDownStyle: PenStyleEditableProperty!
    
    @EditableProperty
    public var fillUpBrushStyle: BrushStyleEditableProperty!
    
    @EditableProperty
    public var fillDownBrushStyle: BrushStyleEditableProperty!
    
    @EditableProperty
    public var dataPointWidth: DoubleEditableProperty!
    
    public init(
        name: String,
        xValues: DataSourceId,
        open: DataSourceId,
        high: DataSourceId,
        low: DataSourceId,
        close: DataSourceId,
        yAxisId: AxisId,
        openTooltipName: String? = "O",
        highTooltipName: String? = "H",
        lowTooltipName: String? = "L",
        closeTooltipName: String? = "C"
    ) {
        super.init(
            name: name,
            xValues: xValues,
            open: open,
            high: high,
            low: low,
            close: close,
            renderableSeries: SCIFastCandlestickRenderableSeries(),
            dataSeries: SCIOhlcDataSeries(xType: .date, yType: .double),
            yAxisId: yAxisId
        )
        
        renderableSeries.seriesInfoProvider = FinanceOhlcSeriesInfoProvider(
            openTooltipName: openTooltipName,
            highTooltipName: highTooltipName,
            lowTooltipName: lowTooltipName,
            closeTooltipName: closeTooltipName
        )
        
        self.strokeUpStyle = PenStyleEditableProperty(
            name: FinanceString.candlestickStrokeUpStyle.name,
            parentName: name,
            initialValue: SCISolidPenStyle(color: Colors.defaultStrokeUp, thickness: Colors.lightThickness)
        ) { [weak self] id, value in
            self?.renderableSeries.strokeUpStyle = value
            self?.onPropertyChanged(propertyId: id)
        }
        
        self.strokeDownStyle = PenStyleEditableProperty(
            name: FinanceString.candlestickStrokeDownStyle.name,
            parentName: name,
            initialValue: SCISolidPenStyle(color: Colors.defaultStrokeDown, thickness: Colors.lightThickness)
        ) { [weak self] id, value in
            self?.renderableSeries.strokeDownStyle = value
            self?.onPropertyChanged(propertyId: id)
        }
        
        self.fillUpBrushStyle = BrushStyleEditableProperty(
            name: FinanceString.candlestickFillUpStyle.name,
            parentName: name,
            initialValue: SCISolidBrushStyle(color: Colors.defaultFillUp)
        ) { [weak self] id, value in
            self?.renderableSeries.fillUpBrushStyle = value
            self?.onPropertyChanged(propertyId: id)
        }
        
        self.fillDownBrushStyle = BrushStyleEditableProperty(
            name: FinanceString.candlestickFillDownStyle.name,
            parentName: name,
            initialValue: SCISolidBrushStyle(color: Colors.defaultFillDown)
        ) { [weak self] id, value in
            self?.renderableSeries.fillDownBrushStyle = value
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
        
        strokeUpStyle.reset()
        strokeDownStyle.reset()
        fillUpBrushStyle.reset()
        fillDownBrushStyle.reset()
        dataPointWidth.reset()
    }
    
    open class FinanceOhlcSeriesInfoProvider: SCIDefaultOhlcSeriesInfoProvider {
        var openTooltipName: String?
        var highTooltipName: String?
        var lowTooltipName: String?
        var closeTooltipName: String?
        
        public init(
            openTooltipName: String?,
            highTooltipName: String?,
            lowTooltipName: String?,
            closeTooltipName: String?
        ) {
            self.openTooltipName = openTooltipName
            self.highTooltipName = highTooltipName
            self.lowTooltipName = lowTooltipName
            self.closeTooltipName = closeTooltipName
            
            super.init(renderableSeriesType: SCIFastCandlestickRenderableSeries.self)
        }
        
        open override func getSeriesTooltipInternal(seriesInfo: SCIOhlcSeriesInfo, modifierType: AnyClass) -> ISCISeriesTooltip {
            return FinanceCandlestickSeriesTooltip(
                seriesInfo: seriesInfo,
                openTooltipName: openTooltipName,
                highTooltipName: highTooltipName,
                lowTooltipName: lowTooltipName,
                closeTooltipName: closeTooltipName
            )
        }
    }
    
    open class FinanceCandlestickSeriesTooltip: SCISeriesTooltipBase<SCIOhlcSeriesInfo> {
        private let openTooltipName: String?
        private let highTooltipName: String?
        private let lowTooltipName: String?
        private let closeTooltipName: String?
        private let fontStyle: SCIFontStyle
        
        public init(
            seriesInfo: SCIOhlcSeriesInfo,
            fontStyle: SCIFontStyle = Constants.defaultTooltipInfoFontStyle,
            openTooltipName: String?,
            highTooltipName: String?,
            lowTooltipName: String?,
            closeTooltipName: String?
        ) {
            self.openTooltipName = openTooltipName
            self.highTooltipName = highTooltipName
            self.lowTooltipName = lowTooltipName
            self.closeTooltipName = closeTooltipName
            self.fontStyle = fontStyle
            
            super.init(seriesInfo: seriesInfo)
            
            self.numberOfLines = 1
        }
        
        open override func internalUpdate(with seriesInfo: SCIOhlcSeriesInfo) {
            let open = seriesInfo.formattedOpenValue.rawString
            let high = seriesInfo.formattedHighValue.rawString
            let low = seriesInfo.formattedLowValue.rawString
            let close = seriesInfo.formattedCloseValue.rawString
            
            let string = createString(open, high, low, close)
            let attributedText = NSMutableAttributedString(string: string)
            
            attributedText.set(
                color: fontStyle.color,
                font: UIFont(descriptor: fontStyle.fontDescriptor, size: fontStyle.fontDescriptor.pointSize),
                textForAttribute: string
            )
            
            var color: UIColor = seriesInfo.seriesColor

            if let openValue = seriesInfo.openValue?.toDouble(),
               let closeValue = seriesInfo.closeValue?.toDouble(),
               let rSeries = renderableSeries as? SCIFastCandlestickRenderableSeries {
                
                let downColor = rSeries.fillDownBrushStyle.color
                let upColor = rSeries.fillUpBrushStyle.color
                
                color = openValue > closeValue ? downColor : upColor
            }
            
            color = color.withAlphaComponent(1)
            
            attributedText.set(color: color, textForAttribute: open)
            attributedText.set(color: color, textForAttribute: high)
            attributedText.set(color: color, textForAttribute: low)
            attributedText.set(color: color, textForAttribute: close)
            
            self.attributedText = attributedText
        }
        
        private func createString(_ open: String, _ high: String, _ low: String, _ close: String) -> String {
            var string = ""
            if let openTooltipName = openTooltipName {
                string.append("\(openTooltipName): ")
            }
            string.append("\(open)")
            
            if let highTooltipName = highTooltipName {
                string.append(" \(highTooltipName):")
            }
            string.append(" \(high)")
            
            if let lowTooltipName = lowTooltipName {
                string.append(" \(lowTooltipName):")
            }
            string.append(" \(low)")
            
            if let closeTooltipName = closeTooltipName {
                string.append(" \(closeTooltipName):")
            }
            string.append(" \(close)")
            
            return string
        }
    }
}
