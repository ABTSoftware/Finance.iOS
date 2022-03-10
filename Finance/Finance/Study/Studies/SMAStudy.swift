//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// SMAStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class SMAStudy: CandleStudyBase {
    private let smaOutputId: DataSourceId
    
    @EditableProperty
    public var smaIndicator: TALibIndicatorProvider.SmaIndicator!
    
    @EditableProperty
    public var smaSeries: LineFinanceSeries!
    
    public init(
        pane: PaneId = PaneId.DEFAULT_PANE,
        id: StudyId = StudyId.uniqueId(name: "SMA"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        yValuesId: DataSourceId = DataSourceId.DEFAULT_Y_VALUES_ID
    ) {
        smaOutputId = DataSourceId.uniqueId(studyId: id, name: "SMA")
        
        super.init(id: id, pane: pane)
        
        smaIndicator = TALibIndicatorProvider.SmaIndicator(
            period: Constants.Indicator.defaultPeriod,
            inputId: yValuesId,
            outputId: smaOutputId
        )
        indicators.add(smaIndicator)
        
        smaSeries = LineFinanceSeries(
            name: FinanceString.rsiIndicatorName.name,
            xValues: xValuesId,
            yValues: smaIndicator.outputId,
            yAxisId: self.yAxisId
        )
        financeSeries.add(smaSeries)
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

        smaIndicator.reset()
        smaSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return editable !== smaIndicator.input
    }
    
    public override var title: String {
        guard let input = smaIndicator.input?.value,
              let period = smaIndicator.period?.value
        else {
            return "SMA"
        }
        return "SMA(\(input) \(period))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return SMATooltip(study: self)
    }
    
    public class SMATooltip: StudyTooltipBase<SMAStudy> {
        private let smaSeriesTooltip: ISCISeriesTooltip
        
        public init(study: SMAStudy) {
            smaSeriesTooltip = study.smaSeries.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                smaSeriesTooltip.place(into: self)
            } else {
                smaSeriesTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: smaSeriesTooltip, point: point)
        }
    }
}
