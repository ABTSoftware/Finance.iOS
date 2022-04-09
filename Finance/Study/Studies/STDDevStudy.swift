//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// StandartDeviationStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class STDDevStudy: CandleStudyBase {
    private let stdOutputId: DataSourceId
    
    @EditableProperty
    public var stdDevIndicator: TALibIndicatorProvider.STDDevIndicator!
    
    @EditableProperty
    public var stdDevSeries: LineFinanceSeries!
    
    public init(
        pane: PaneId,
        id: StudyId = StudyId.uniqueId(name: "STDDEV"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        yValuesId: DataSourceId = DataSourceId.DEFAULT_Y_VALUES_ID
    ) {
        stdOutputId = DataSourceId.uniqueId(studyId: id, name: "STDDEV")
        
        super.init(id: id, pane: pane)
        
        stdDevIndicator = TALibIndicatorProvider.STDDevIndicator(
            period: Constants.Indicator.defaultPeriod,
            dev: Constants.Indicator.defaultDev,
            inputId: yValuesId,
            outputId: stdOutputId
        )
        indicators.add(stdDevIndicator)
        
        stdDevSeries = LineFinanceSeries(
            name: FinanceString.stdDevIndicatorName.name,
            xValues: xValuesId,
            yValues: stdDevIndicator.outputId,
            yAxisId: self.yAxisId
        )
        financeSeries.add(stdDevSeries)
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

        stdDevIndicator.reset()
        stdDevSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return editable !== stdDevIndicator.input
    }
    
    public override var title: String {
        guard let input = stdDevIndicator.input?.value,
              let period = stdDevIndicator.period?.value,
              let dev = stdDevIndicator.dev?.value
        else {
            return "STDDEV"
        }
        return "STDDEV(\(input) \(period) \(dev))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return STDDevTooltip(study: self)
    }
    
    public class STDDevTooltip: StudyTooltipBase<STDDevStudy> {
        private let stdDevSeriesTooltip: ISCISeriesTooltip
        
        public init(study: STDDevStudy) {
            stdDevSeriesTooltip = study.stdDevSeries.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                stdDevSeriesTooltip.place(into: self)
            } else {
                stdDevSeriesTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: stdDevSeriesTooltip, point: point)
        }
    }
}
