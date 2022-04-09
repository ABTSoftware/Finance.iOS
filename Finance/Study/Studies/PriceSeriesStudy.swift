//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// PriceSeriesStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class PriceSeriesStudy: CandleStudyBase, PricesStudyTooltipDelegate {
    private let volumeAxisId: AxisId
    private var lastLegendInstrumentModel: LegendInstrumentModel?
    
    @EditableProperty
    public var priceSeries: CandlestickFinanceSeries!
    
    @EditableProperty
    public var volumeSeries: ColumnFinanceSeries!
    
    var volumeYAxis: FinanceVolumeYAxis!
    
    private var seriesValueModifier: SCISeriesValueModifier!
    
    public init(
        pane: PaneId = PaneId.DEFAULT_PANE,
        id: StudyId = StudyId.uniqueId(name: "PriceSeries"),
        ohlcvDataSourceId: OhlcvDataSourceId = OhlcvDataSourceId.DEFAULT_OHLCV_VALUES_IDS
    ) {
        volumeAxisId = AxisId(pane: pane, study: id, axisName: "VolumeAxis")
        volumeYAxis = FinanceVolumeYAxis(name: FinanceString.studyVolumeYAxis.name, axisId: volumeAxisId)
        
        super.init(id: StudyId.uniqueId(name: "PriceSeries"), pane: pane)
        
        priceSeries = CandlestickFinanceSeries(
            name: FinanceString.studyPriceSeries.name,
            xValues: ohlcvDataSourceId.xValuesId,
            open: ohlcvDataSourceId.openValuesId,
            high: ohlcvDataSourceId.highValuesId,
            low: ohlcvDataSourceId.lowValuesId,
            close: ohlcvDataSourceId.closeValuesId,
            yAxisId: self.yAxisId
        )
        
        volumeSeries = ColumnFinanceSeries(
            name: FinanceString.studyVolumeSeries.name,
            xValues: ohlcvDataSourceId.xValuesId,
            yValues: ohlcvDataSourceId.volumeValuesId,
            yAxisId: self.volumeAxisId,
            yTooltipName: "Vol"
        )
        
        volumeSeries.opacity.updateInitialValue(0.2)
        
        let paletteProvider = FinanceSeriesPaletteProvider(inputs: [ohlcvDataSourceId.openValuesId, ohlcvDataSourceId.closeValuesId]) { [weak self] map, index in
            guard let self = self else {
                return UIColor.white
            }
            
            guard
                let open = map[ohlcvDataSourceId.openValuesId]?.getValueAt(index),
                let close = map[ohlcvDataSourceId.closeValuesId]?.getValueAt(index)
            else {
                return UIColor.white
            }
            
            let opacity = CGFloat(self.volumeSeries.opacity.value)
            
            return open > close ?
                self.priceSeries.fillDownBrushStyle.value.color.withAlphaComponent(opacity) :
                self.priceSeries.fillUpBrushStyle.value.color.withAlphaComponent(opacity)
        }
        volumeSeries.paletteProvider = paletteProvider
        
        financeSeries.add(priceSeries)
        financeSeries.add(volumeSeries)
        financeYAxes.add(volumeYAxis)
        
        seriesValueModifier = SCISeriesValueModifier(markerFactory: HorizontalLineSeriesValueMarkerFactory(predicate: { [weak self] rs in
            guard
                let self = self,
                let rs = rs as? ISCIRenderableSeries
            else { return false }
            
            return rs === self.priceSeries.renderableSeries
        }))
    }
    
    public override func onPropertyChanged(_ propertyId: PropertyId) {
        super.onPropertyChanged(propertyId)
        
        if priceSeries.dataPointWidth.propertyId == propertyId {
            volumeSeries.dataPointWidth.trySetValue(priceSeries.dataPointWidth.value)
        }
    }
    
    public override func placeInto(pane: IPane) {
        super.placeInto(pane: pane)
        
        pane.chart.chartModifiers.add(items: seriesValueModifier)
        
        if let mainPane = pane as? MainPane {
            mainPane.excludeAutoRangeAxisId(volumeAxisId)
        }
    }
    
    public override func removeFrom(pane: IPane) {
        pane.chart.chartModifiers.remove(seriesValueModifier)
        
        if let mainPane = pane as? MainPane {
            mainPane.removeExcludedAutoRangeAxisId(volumeAxisId)
        }
        
        super.removeFrom(pane: pane)
    }
    
    // MARK: - IFinanceChartEventListener
    
    public override func onFinanceChartEvent(_ event: IFinanceChartEvent) {
        super.onFinanceChartEvent(event)
        
        if let event = event as? LegendInstrumentModelChangedEvent,
           let model = event.model {
            lastLegendInstrumentModel = model
            invalidateStudy()
        }
        
        if let event = event as? InstrumentPriceFormatChangedEvent {
            let priceFormat = event.priceFormat
            
            yAxis.textFormatting.updateInitialValue(priceFormat)
            yAxis.cursorTextFormatting.updateInitialValue(priceFormat)
        }
    }
    
    public override func reset() {
        super.reset()

        priceSeries.reset()
        volumeSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return
            editable !== volumeSeries.fillStyle &&
            editable !== volumeSeries.strokeStyle &&
            editable !== volumeSeries.dataPointWidth
    }
    
    public override var title: String {
        return lastLegendInstrumentModel?.name ?? ""
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        let tooltip = PricesStudyTooltip(study: self)
        tooltip.delegate = self
        
        return tooltip
    }
    
    func onTitlePressed() {
        dispatchStudyEvent(StudyTitlePressedEvent(study: self))
    }
    
    class FinanceVolumeYAxis: FinanceNumericYAxis {
        override func createAxis() -> SCINumericAxis {
            let axis = super.createAxis()
            axis.growBy = SCIDoubleRange(min: 0.0, max: 4.0)
            
            return axis
        }
    }
    
    class PricesStudyTooltip: StudyTooltipBase<PriceSeriesStudy> {
        private lazy var priceChangePercentFormatter = PercentFormatter()
        
        private let upColor = UIColor.fillUp
        private let downColor = UIColor.fillDown
        
        private let priceSeriesTooltip: ISCISeriesTooltip
        private let volumeSeriesTooltip: ISCISeriesTooltip
        
        weak var delegate: PricesStudyTooltipDelegate?
        
        init(study: PriceSeriesStudy) {
            priceSeriesTooltip = study.priceSeries.getTooltip()
            volumeSeriesTooltip = study.volumeSeries.getTooltip()
            
            super.init(study: study)
            
            titleLabel.isUserInteractionEnabled = true
            titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTitlePressed)))
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                priceSeriesTooltip.place(into: self)
                volumeSeriesTooltip.place(into: self)
            } else {
                priceSeriesTooltip.remove(from: self)
                volumeSeriesTooltip.remove(from: self)
            }
        }
        
        override func updateTitleView(titleLabel: UILabel) {
            guard
                let legendInstrumentInfo = study.lastLegendInstrumentModel,
                let labelProvider = self.priceSeriesTooltip.seriesInfo.renderableSeries.yAxis?.labelProvider
            else { return }
                
            let lastPrice = labelProvider.formatLabel(legendInstrumentInfo.lastPrice as ISCIComparable)
            let priceChange = labelProvider.formatLabel(legendInstrumentInfo.priceChange as ISCIComparable)
            let priceChangePercent = priceChangePercentFormatter.string(from: legendInstrumentInfo.priceChangePercent) ?? ""

            let title = study.title
            let infoString = " \(lastPrice) \(priceChange) (\(priceChangePercent))"
            
            let text = title + infoString
            let attributedText = NSMutableAttributedString(string: text)

            attributedText.set(
                color: titleLabel.textColor,
                font: titleLabel.font,
                textForAttribute: title
            )
            
            let infoColor = legendInstrumentInfo.priceChange < 0 ? downColor : upColor
            attributedText.set(
                color: infoColor,
                font: titleLabel.font,
                textForAttribute: infoString
            )
            
            titleLabel.attributedText = attributedText
        }
        
        override func update(point: CGPoint) {
            tryUpdate(tooltip: priceSeriesTooltip, point: point)
            tryUpdate(tooltip: volumeSeriesTooltip, point: point)
        }
        
        @objc private func onTitlePressed() {
            delegate?.onTitlePressed()
            
            titleLabel.selectionHapticFeedback()
        }
    }
}

protocol PricesStudyTooltipDelegate: AnyObject {
    func onTitlePressed()
}
