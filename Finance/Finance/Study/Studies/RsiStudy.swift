//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// RSIStudy.swift is part of the SCICHART® SciTraider App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTraider App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class RSIStudy: CandleStudyBase {
    private let rsiOutputId: DataSourceId
    
    @EditableProperty
    public var rsiIndicator: TALibIndicatorProvider.RSIIndicator!
    
    @EditableProperty
    public var rsiSeries: LineFinanceSeries!
    
    public init(
        pane: PaneId,
        id: StudyId = StudyId.uniqueId(name: "RSI"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        yValuesId: DataSourceId = DataSourceId.DEFAULT_Y_VALUES_ID
    ) {
        rsiOutputId = DataSourceId.uniqueId(studyId: id, name: "RSI")
        
        super.init(id: id, pane: pane)
        
        rsiIndicator = TALibIndicatorProvider.RSIIndicator(
            period: Constants.Indicator.defaultPeriod,
            inputId: yValuesId,
            outputId: rsiOutputId
        )
        indicators.add(rsiIndicator)
        
        rsiSeries = LineFinanceSeries(
            name: FinanceString.rsiIndicatorName.name,
            xValues: xValuesId,
            yValues: rsiIndicator.outputId,
            yAxisId: self.yAxisId
        )
        financeSeries.add(rsiSeries)
    }
    
    public override func reset() {
        super.reset()

        rsiIndicator.reset()
        rsiSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return editable !== rsiIndicator.input
    }
    
    public override var title: String {
        guard
            let input = rsiIndicator.input?.value,
            let period = rsiIndicator.period?.value
        else {
            return "RSI"
        }
        return "RSI(\(input) \(period))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return RsiTooltip(study: self)
    }
    
    public class RsiTooltip: StudyTooltipBase<RSIStudy> {
        private let rsiSeriesTooltip: ISCISeriesTooltip
        
        public init(study: RSIStudy) {
            rsiSeriesTooltip = study.rsiSeries.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                rsiSeriesTooltip.place(into: self)
            } else {
                rsiSeriesTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: rsiSeriesTooltip, point: point)
        }
    }
}
