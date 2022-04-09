//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// SARStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class SARStudy: CandleStudyBase {
    private let sarOutputId: DataSourceId

    @EditableProperty
    public var sarIndicator: TALibIndicatorProvider.SARIndicator!
    
    @EditableProperty
    public var sarSeries: LineFinanceSeries!
        
    public init(
        pane: PaneId = PaneId.DEFAULT_PANE,
        id: StudyId = StudyId.uniqueId(name: "SAR"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        highValuesId: DataSourceId = DataSourceId.DEFAULT_HIGH_VALUES_ID,
        lowValuesId: DataSourceId = DataSourceId.DEFAULT_LOW_VALUES_ID
    ) {
        sarOutputId = DataSourceId.uniqueId(studyId: id, name: "SAR")
        
        super.init(id: id, pane: pane)
        
        sarIndicator = TALibIndicatorProvider.SARIndicator(
            acceleration: Constants.Indicator.defaultAcceleration,
            maximum: Constants.Indicator.defaultMaximum,
            inputHighId: highValuesId,
            inputLowId: lowValuesId,
            outputId: sarOutputId
        )
        indicators.add(sarIndicator)
        
        sarSeries = LineFinanceSeries(
            name: FinanceString.sarIndicatorName.name,
            xValues: xValuesId,
            yValues: sarIndicator.outputId,
            yAxisId: self.yAxisId
        )
        financeSeries.add(sarSeries)
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

        sarIndicator.reset()
        sarSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return
            editable !== sarIndicator.inputHigh &&
            editable !== sarIndicator.inputLow
    }
    
    public override var title: String {
        guard
            let inputHigh = sarIndicator.inputHigh?.value,
            let inputLow = sarIndicator.inputLow?.value,
            let acceleration = sarIndicator.acceleration?.value,
            let maximum = sarIndicator.maximum?.value
        else {
            return "SAR"
        }
        return "SAR(\(inputHigh) \(inputLow) \(acceleration) \(maximum))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return SARTooltip(study: self)
    }
    
    public class SARTooltip: StudyTooltipBase<SARStudy> {
        
        private let sarSeriesTooltip: ISCISeriesTooltip
        
        public init(study: SARStudy) {
            
            sarSeriesTooltip = study.sarSeries.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                sarSeriesTooltip.place(into: self)
            } else {
                sarSeriesTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: sarSeriesTooltip, point: point)
        }
    }
}
