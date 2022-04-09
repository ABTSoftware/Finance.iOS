//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// XyFinanceSeriesBase.swift is part of SCICHART®, High Performance Scientific Charts
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
import SciChart.Protected.SCISeriesTooltipBase

public class XyFinanceSeriesBase<TRenderableSeries: SCIXyRenderableSeriesBase, TDataSeries: ISCIXyDataSeries>: FinanceSeriesBase<TRenderableSeries, TDataSeries> {
    
    private var xValues: DataSourceEditableProperty!
    private var yValues: DataSourceEditableProperty!
        
    public init(
        name: String,
        xValues: DataSourceId,
        yValues: DataSourceId,
        renderableSeries: TRenderableSeries,
        dataSeries: TDataSeries,
        yAxisId: AxisId,
        yTooltipName: String?
    ) {
        super.init(
            name: name,
            renderableSeries: renderableSeries,
            dataSeries: dataSeries,
            yAxisId: yAxisId
        )
        
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
            initialValue: yValues)
        { [weak self] _, value in
            self?.dependsOn(propertyId: FinanceString.yValues, value: value)
        }
        
        renderableSeries.seriesInfoProvider = FinanceXySeriesInfoProvider(yTooltipName: yTooltipName)
    }
    
    override func onDataDrasticallyChanged(dataManager: IDataManager) {
        let suspender = renderableSeries.suspendUpdates()
        defer {
            suspender.dispose()
        }
        
        dataSeries.clear()
        
        if let xValues = dataManager.getXValues(id: self.xValues.value),
           let yValues = dataManager.getYValues(id: self.yValues.value) {
            dataSeries.append(x: xValues, y: yValues)
        }
    }

    public override func reset() {
        super.reset()
        
        xValues.reset()
        yValues.reset()
    }
    
    open class FinanceXySeriesInfoProvider: SCIDefaultXySeriesInfoProvider {
        private let yTooltipName: String?
        
        public init(yTooltipName: String?) {
            self.yTooltipName = yTooltipName
            
            super.init(renderableSeriesType: SCIXyRenderableSeriesBase.self)
        }
        
        open override func getSeriesTooltipInternal(seriesInfo: SCIXySeriesInfo, modifierType: AnyClass) -> ISCISeriesTooltip {
            return FinanceXySeriesTooltip(seriesInfo: seriesInfo, yTooltipName: yTooltipName)
        }
    }
    
    open class FinanceXySeriesTooltip: SCISeriesTooltipBase<SCIXySeriesInfo> {
        private var infoTextColor: UIColor?
        private let yTooltipName: String?
        private let fontStyle: SCIFontStyle
        
        public init(
            seriesInfo: SCIXySeriesInfo,
            fontStyle: SCIFontStyle = Constants.defaultTooltipInfoFontStyle,
            yTooltipName: String?
        ) {
            self.yTooltipName = yTooltipName
            self.fontStyle = fontStyle
            
            super.init(seriesInfo: seriesInfo)

            self.numberOfLines = 1
        }
        
        open override func update(_ hitTestInfo: SCIHitTestInfo, interpolate: Bool) {
            infoTextColor = tryGetColorFromPaletteProvider(hitTestInfo)
            
            super.update(hitTestInfo, interpolate: interpolate)
        }
        
        open override func internalUpdate(with seriesInfo: SCIXySeriesInfo) {
            let yValue = seriesInfo.formattedYValue.rawString
            
            let string = createString(yValue)
            let textColor = (infoTextColor ?? seriesInfo.seriesColor).withAlphaComponent(1)

            let attributedText = NSMutableAttributedString(string: string)
            
            attributedText.set(
                color: fontStyle.color,
                font: UIFont(descriptor: fontStyle.fontDescriptor, size: fontStyle.fontDescriptor.pointSize),
                textForAttribute: string
            )
            attributedText.set(color: textColor, textForAttribute: yValue)
            
            self.attributedText = attributedText
        }
        
        private func createString(_ yValue: String) -> String {
            var string = ""
            if let yTooltipName = yTooltipName {
                string.append("\(yTooltipName): ")
            }
            string.append(yValue)
            
            return string
        }
        
        private func tryGetColorFromPaletteProvider(_ hitTestInfo: SCIHitTestInfo) -> UIColor? {
            var colors: SCIUnsignedIntegerValues?
            
            if let paletteProvider = renderableSeries.paletteProvider as? ISCIFillPaletteProvider {
                colors = paletteProvider.fillColors
            } else if let paletteProvider = renderableSeries.paletteProvider as? ISCIStrokePaletteProvider {
                colors = paletteProvider.strokeColors
            }
            
            if let colors = colors {
                let index = hitTestInfo.pointSeriesIndex
                if index < colors.count {
                    return UIColor.fromARGBColorCode(colors.getValueAt(index))
                }
            }
            
            return nil
        }
    }
}
