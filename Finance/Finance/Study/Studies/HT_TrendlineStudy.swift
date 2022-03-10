//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// HT_TrendlineStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class HT_TrendlineStudy: CandleStudyBase {
    private let trendlineOutputId: DataSourceId
    
    @EditableProperty
    public var trendlineIndicator: TALibIndicatorProvider.HT_TrendlineIndicator!
    
    @EditableProperty
    public var trendlineSeries: LineFinanceSeries!
    
    public init(
        pane: PaneId = PaneId.DEFAULT_PANE,
        id: StudyId = StudyId.uniqueId(name: "HT_TRENDLINE"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        yValuesId: DataSourceId = DataSourceId.DEFAULT_Y_VALUES_ID
    ) {
        trendlineOutputId = DataSourceId.uniqueId(studyId: id, name: "HT_TRENDLINE")
        
        super.init(id: id, pane: pane)
        
        trendlineIndicator = TALibIndicatorProvider.HT_TrendlineIndicator(
            inputId: yValuesId,
            outputId: trendlineOutputId
        )
        indicators.add(trendlineIndicator)
        
        trendlineSeries = LineFinanceSeries(
            name: FinanceString.htTrendlineIndicatorName.name,
            xValues: xValuesId,
            yValues: trendlineIndicator.outputId,
            yAxisId: self.yAxisId
        )
        financeSeries.add(trendlineSeries)
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

        trendlineIndicator.reset()
        trendlineSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return editable !== trendlineIndicator.input
    }
    
    public override var title: String {
        return "HT_TRENDLINE"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return TrendlineTooltip(study: self)
    }
    
    public class TrendlineTooltip: StudyTooltipBase<HT_TrendlineStudy> {
        private let trendlineSeriesTooltip: ISCISeriesTooltip
        
        public init(study: HT_TrendlineStudy) {
            trendlineSeriesTooltip = study.trendlineSeries.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                trendlineSeriesTooltip.place(into: self)
            } else {
                trendlineSeriesTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: trendlineSeriesTooltip, point: point)
        }
    }
}
