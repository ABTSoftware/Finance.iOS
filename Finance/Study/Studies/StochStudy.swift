//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// StochStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class StochStudy: CandleStudyBase {
    private let slowKOutputId: DataSourceId
    private let slowDOutputId: DataSourceId
    
    @EditableProperty
    public var stochIndicator: TALibIndicatorProvider.StochIndicator!
    
    @EditableProperty
    public var slowKSeries: LineFinanceSeries!
    
    @EditableProperty
    public var slowDSeries: LineFinanceSeries!
    
    public init(
        pane: PaneId,
        id: StudyId = StudyId.uniqueId(name: "STOCH"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        highValuesId: DataSourceId = DataSourceId.DEFAULT_HIGH_VALUES_ID,
        lowValuesId: DataSourceId = DataSourceId.DEFAULT_LOW_VALUES_ID,
        closeValuesId: DataSourceId = DataSourceId.DEFAULT_CLOSE_VALUES_ID
    ) {
        slowKOutputId = DataSourceId.uniqueId(studyId: id, name: "SlowK")
        slowDOutputId = DataSourceId.uniqueId(studyId: id, name: "SlowD")
        
        super.init(id: id, pane: pane)
        
        stochIndicator = TALibIndicatorProvider.StochIndicator(
            fastK: Constants.Indicator.defaultFast,
            slowK: Constants.Indicator.defaultSlow,
            slowD: Constants.Indicator.defaultSlow,
            slowK_maType: Constants.Indicator.defaultMaType,
            slowD_maType: Constants.Indicator.defaultMaType,
            inputHighId: highValuesId,
            inputLowId: lowValuesId,
            inputCloseId: closeValuesId,
            slowKId: slowKOutputId,
            slowDId: slowDOutputId
        )
        
        indicators.add(stochIndicator)
        
        slowKSeries = LineFinanceSeries(
            name: FinanceString.stochSlowKId.name,
            xValues: xValuesId,
            yValues: stochIndicator.slowKId,
            yAxisId: self.yAxisId
        )
        
        slowDSeries = LineFinanceSeries(
            name: FinanceString.stochSlowDId.name,
            xValues: xValuesId,
            yValues: stochIndicator.slowDId,
            yAxisId: self.yAxisId
        )
        slowDSeries.strokeStyle.updateInitialValue(SCISolidPenStyle(color: Colors.defaultRed, thickness: Colors.defaultThickness))
        
        financeSeries.add(slowKSeries)
        financeSeries.add(slowDSeries)
    }
    
    public override func reset() {
        super.reset()

        stochIndicator.reset()
        slowKSeries.reset()
        slowDSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return
            editable !== stochIndicator.inputClose &&
            editable !== stochIndicator.inputHigh &&
            editable !== stochIndicator.inputLow
    }
    
    public override var title: String {
        guard
            let fastK = stochIndicator.fastK?.value,
            let slowK_maType = stochIndicator.slowK_maType?.enumValue.name,
            let slowK = stochIndicator.slowK?.value,
            let slowD_maType = stochIndicator.slowD_maType?.enumValue.name,
            let slowD = stochIndicator.slowD?.value
        else {
            return "STOCH"
        }
        
        return "STOCH(\(fastK) \(slowK_maType) \(slowK) \(slowD_maType) \(slowD))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return StochTooltip(study: self)
    }
    
    public class StochTooltip: StudyTooltipBase<StochStudy> {
        
        private let slowKTooltip: ISCISeriesTooltip
        private let slowDTooltip: ISCISeriesTooltip
        
        public init(study: StochStudy) {
            slowKTooltip = study.slowKSeries.getTooltip()
            slowDTooltip = study.slowDSeries.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                slowKTooltip.place(into: self)
                slowDTooltip.place(into: self)
            } else {
                slowKTooltip.remove(from: self)
                slowDTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: slowKTooltip, point: point)
            tryUpdate(tooltip: slowDTooltip, point: point)
        }
    }
}
