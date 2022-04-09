//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// BBandsStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class BBandsStudy: CandleStudyBase {
    private let lowerBandId: DataSourceId
    private let middleBandId: DataSourceId
    private let upperBandId: DataSourceId
    
    @EditableProperty
    public var bBandsIndicator: TALibIndicatorProvider.BBandsIndicator!
    
    @EditableProperty
    public var midBBands: LineFinanceSeries!
    
    @EditableProperty
    public var bbandsBand: BandFinanceSeries!
    
    public init(
        pane: PaneId = PaneId.DEFAULT_PANE,
        id: StudyId = StudyId.uniqueId(name: "BBANDS"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        yValuesId: DataSourceId = DataSourceId.DEFAULT_Y_VALUES_ID
    ) {
        lowerBandId = DataSourceId.uniqueId(studyId: id, name: "LowerBand")
        middleBandId = DataSourceId.uniqueId(studyId: id, name: "MiddleBand")
        upperBandId = DataSourceId.uniqueId(studyId: id, name: "UpperBand")
        
        super.init(id: id, pane: pane)
        
        bBandsIndicator = TALibIndicatorProvider.BBandsIndicator(
            period: Constants.Indicator.defaultPeriod,
            devUp: Constants.Indicator.defaultDev,
            devDown: Constants.Indicator.defaultDev,
            maType: Constants.Indicator.defaultMaType,
            inputId: yValuesId,
            lowerBandId: lowerBandId,
            middleBandId: middleBandId,
            upperBandId: upperBandId
        )
        indicators.add(bBandsIndicator)
        
        midBBands = LineFinanceSeries(
            name: FinanceString.bBandsMidId.name,
            xValues: xValuesId,
            yValues: bBandsIndicator.middleBandId,
            yAxisId: self.yAxisId
        )
        midBBands.strokeStyle.updateInitialValue(SCISolidPenStyle(color: Colors.defaultRed, thickness: Colors.defaultThickness))
        
        bbandsBand = BandFinanceSeries(
            name: FinanceString.bBandsBandId.name,
            xValues: xValuesId,
            yValues: upperBandId,
            y1Values: lowerBandId,
            yAxisId: self.yAxisId
        )
        
        financeSeries.add(midBBands)
        financeSeries.add(bbandsBand)
    }
    
    public override func onFinanceChartEvent(_ event: IFinanceChartEvent) {
        if let event = event as? InstrumentPriceFormatChangedEvent {
            let priceFormat = event.priceFormat
            
            yAxis.textFormatting.updateInitialValue(priceFormat)
            yAxis.cursorTextFormatting.updateInitialValue(priceFormat)
        }
    }
    
    public override func reset() {
        super.reset()

        bBandsIndicator.reset()
        midBBands.reset()
        bbandsBand.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return
            editable !== bbandsBand.fillY1BrushStyle &&
            editable !== bBandsIndicator.input
    }
    
    public override var title: String {
        guard
            let input = bBandsIndicator.input?.value,
            let period = bBandsIndicator.period?.value,
            let dev = bBandsIndicator.devUp?.value,
            let maType = bBandsIndicator.maType?.enumValue.name
        else {
            return "BB"
        }
        
        return "BB(\(period) \(input) \(dev) \(maType))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return BBandsTooltip(study: self)
    }
    
    public class BBandsTooltip: StudyTooltipBase<BBandsStudy> {
        
        private let bbandsBandTooltip: ISCISeriesTooltip
        private let midBandsTooltip: ISCISeriesTooltip
        
        public init(study: BBandsStudy) {
            bbandsBandTooltip = study.bbandsBand.getTooltip()
            midBandsTooltip = study.midBBands.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                midBandsTooltip.place(into: self)
                bbandsBandTooltip.place(into: self)
            } else {
                bbandsBandTooltip.remove(from: self)
                midBandsTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: bbandsBandTooltip, point: point)
            tryUpdate(tooltip: midBandsTooltip, point: point)
        }
    }
}
