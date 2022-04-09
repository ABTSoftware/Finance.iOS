//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// ATRStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class ATRStudy: CandleStudyBase {
    private let atrOutputId: DataSourceId

    @EditableProperty
    public var atrIndicator: TALibIndicatorProvider.ATRIndicator!
    
    @EditableProperty
    public var atrSeries: LineFinanceSeries!
        
    public init(
        pane: PaneId,
        id: StudyId = StudyId.uniqueId(name: "ATR"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        highValuesId: DataSourceId = DataSourceId.DEFAULT_HIGH_VALUES_ID,
        lowValuesId: DataSourceId = DataSourceId.DEFAULT_LOW_VALUES_ID,
        closeValuesId: DataSourceId = DataSourceId.DEFAULT_CLOSE_VALUES_ID
    ) {
        atrOutputId = DataSourceId.uniqueId(studyId: id, name: "ATR")
        
        super.init(id: id, pane: pane)
        
        atrIndicator = TALibIndicatorProvider.ATRIndicator(
            period: Constants.Indicator.defaultPeriod,
            inputHighId: highValuesId,
            inputLowId: lowValuesId,
            inputCloseId: closeValuesId,
            outputId: atrOutputId
        )
        
        indicators.add(atrIndicator)
        
        atrSeries = LineFinanceSeries(
            name: FinanceString.atrIndicatorName.name,
            xValues: xValuesId,
            yValues: atrIndicator.outputId,
            yAxisId: self.yAxisId
        )
        financeSeries.add(atrSeries)
    }
    
    public override func reset() {
        super.reset()

        atrIndicator.reset()
        atrSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return
            editable !== atrIndicator.inputClose &&
            editable !== atrIndicator.inputHigh &&
            editable !== atrIndicator.inputLow
    }
    
    public override var title: String {
        guard let inputHigh = atrIndicator.inputHigh?.value,
              let inputLow = atrIndicator.inputLow?.value,
              let inputClose = atrIndicator.inputClose?.value,
              let period = atrIndicator.period?.value
        else {
            return "ATR"
        }
        return "ATR(\(inputHigh) \(inputLow) \(inputClose) \(period))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return ATRTooltip(study: self)
    }
    
    public class ATRTooltip: StudyTooltipBase<ATRStudy> {
        
        private let atrSeriesTooltip: ISCISeriesTooltip
        
        public init(study: ATRStudy) {
            
            atrSeriesTooltip = study.atrSeries.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                atrSeriesTooltip.place(into: self)
            } else {
                atrSeriesTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: atrSeriesTooltip, point: point)
        }
    }
}
