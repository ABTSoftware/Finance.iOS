//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// ADXStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class ADXStudy: CandleStudyBase {
    private let adxOutputId: DataSourceId
    
    @EditableProperty
    public var adxIndicator: TALibIndicatorProvider.ADXIndicator!
    
    @EditableProperty
    public var adxSeries: LineFinanceSeries!
    
    public init(
        pane: PaneId,
        id: StudyId = StudyId.uniqueId(name: "ADX"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        highValuesId: DataSourceId = DataSourceId.DEFAULT_HIGH_VALUES_ID,
        lowValuesId: DataSourceId = DataSourceId.DEFAULT_LOW_VALUES_ID,
        closeValuesId: DataSourceId = DataSourceId.DEFAULT_CLOSE_VALUES_ID
    ) {
        adxOutputId = DataSourceId.uniqueId(studyId: id, name: "ADX")
        
        super.init(id: id, pane: pane)
        
        adxIndicator = TALibIndicatorProvider.ADXIndicator(
            period: Constants.Indicator.defaultPeriod,
            inputHighId: highValuesId,
            inputLowId: lowValuesId,
            inputCloseId: closeValuesId,
            outputId: adxOutputId
        )
        indicators.add(adxIndicator)
        
        adxSeries = LineFinanceSeries(
            name: FinanceString.adxIndicatorName.name,
            xValues: xValuesId,
            yValues: adxIndicator.outputId,
            yAxisId: self.yAxisId
        )
        financeSeries.add(adxSeries)
    }
    
    public override func reset() {
        super.reset()

        adxIndicator.reset()
        adxSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return
            editable !== adxIndicator.inputClose &&
            editable !== adxIndicator.inputHigh &&
            editable !== adxIndicator.inputLow
    }
    
    public override var title: String {
        guard
            let inputHigh = adxIndicator.inputHigh?.value,
            let inputLow = adxIndicator.inputLow?.value,
            let inputClose = adxIndicator.inputClose?.value,
            let period = adxIndicator.period?.value
        else {
            return "ADX"
        }
        return "ADX(\(inputHigh) \(inputLow) \(inputClose) \(period))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return ADXTooltip(study: self)
    }
    
    public class ADXTooltip: StudyTooltipBase<ADXStudy> {
        private let adxSeriesTooltip: ISCISeriesTooltip
        
        public init(study: ADXStudy) {
            adxSeriesTooltip = study.adxSeries.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                adxSeriesTooltip.place(into: self)
            } else {
                adxSeriesTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: adxSeriesTooltip, point: point)
        }
    }
}
