//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// EMAStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class EMAStudy: CandleStudyBase {
    private let emaOutputId: DataSourceId
    
    @EditableProperty
    public var emaIndicator: TALibIndicatorProvider.EMAIndicator!
    
    @EditableProperty
    public var emaSeries: LineFinanceSeries!
        
    public init(
        pane: PaneId = PaneId.DEFAULT_PANE,
        id: StudyId = StudyId.uniqueId(name: "EMA"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        yValuesId: DataSourceId = DataSourceId.DEFAULT_Y_VALUES_ID
    ) {
        emaOutputId = DataSourceId.uniqueId(studyId: id, name: "EMA")
        
        super.init(id: id, pane: pane)
        
        emaIndicator = TALibIndicatorProvider.EMAIndicator(
            period: Constants.Indicator.defaultPeriod,
            inputId: yValuesId,
            outputId: emaOutputId
        )
        indicators.add(emaIndicator)
        
        emaSeries = LineFinanceSeries(
            name: FinanceString.emaIndicatorName.name,
            xValues: xValuesId,
            yValues: emaIndicator.outputId,
            yAxisId: self.yAxisId
        )
        financeSeries.add(emaSeries)
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

        emaIndicator.reset()
        emaSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return editable !== emaIndicator.input
    }
    
    public override var title: String {
        guard let input = emaIndicator.input?.value,
              let period = emaIndicator.period?.value
        else {
            return "EMA"
        }
        return "EMA(\(input) \(period))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return EMATooltip(study: self)
    }
    
    public class EMATooltip: StudyTooltipBase<EMAStudy> {
        
        private let emaSeriesTooltip: ISCISeriesTooltip
        
        public init(study: EMAStudy) {
            
            emaSeriesTooltip = study.emaSeries.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                emaSeriesTooltip.place(into: self)
            } else {
                emaSeriesTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: emaSeriesTooltip, point: point)
        }
    }
}
