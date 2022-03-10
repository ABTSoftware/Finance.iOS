//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// CCIStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class CCIStudy: CandleStudyBase {
    private let cciOutputId: DataSourceId

    @EditableProperty
    public var cciIndicator: TALibIndicatorProvider.CCIIndicator!
    
    @EditableProperty
    public var cciSeries: LineFinanceSeries!
        
    public init(
        pane: PaneId,
        id: StudyId = StudyId.uniqueId(name: "CCI"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        highValuesId: DataSourceId = DataSourceId.DEFAULT_HIGH_VALUES_ID,
        lowValuesId: DataSourceId = DataSourceId.DEFAULT_LOW_VALUES_ID,
        closeValuesId: DataSourceId = DataSourceId.DEFAULT_CLOSE_VALUES_ID
    ) {
        cciOutputId = DataSourceId.uniqueId(studyId: id, name: "CCI")
        
        super.init(id: id, pane: pane)
        
        cciIndicator = TALibIndicatorProvider.CCIIndicator(
            period: Constants.Indicator.defaultPeriod,
            inputHighId: highValuesId,
            inputLowId: lowValuesId,
            inputCloseId: closeValuesId,
            outputId: cciOutputId
        )
        indicators.add(cciIndicator)
        
        cciSeries = LineFinanceSeries(
            name: FinanceString.cciIndicatorName.name,
            xValues: xValuesId,
            yValues: cciIndicator.outputId,
            yAxisId: self.yAxisId
        )
        financeSeries.add(cciSeries)
    }
    
    public override func reset() {
        super.reset()

        cciIndicator.reset()
        cciSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return
            editable !== cciIndicator.inputClose &&
            editable !== cciIndicator.inputHigh &&
            editable !== cciIndicator.inputLow
    }
    
    public override var title: String {
        guard let inputHigh = cciIndicator.inputHigh?.value,
              let inputLow = cciIndicator.inputLow?.value,
              let inputClose = cciIndicator.inputClose?.value,
              let period = cciIndicator.period?.value
        else {
            return "CCI"
        }
        return "CCI(\(inputHigh) \(inputLow) \(inputClose) \(period))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return CCITooltip(study: self)
    }
    
    public class CCITooltip: StudyTooltipBase<CCIStudy> {
        
        private let cciSeriesTooltip: ISCISeriesTooltip
        
        public init(study: CCIStudy) {
            
            cciSeriesTooltip = study.cciSeries.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                cciSeriesTooltip.place(into: self)
            } else {
                cciSeriesTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: cciSeriesTooltip, point: point)
        }
    }
}
