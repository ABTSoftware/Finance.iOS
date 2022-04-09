//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// MacdStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class MacdStudy: CandleStudyBase {
    private let macdId: DataSourceId
    private let macdSignalId: DataSourceId
    private let macdHistId: DataSourceId
    
    @EditableProperty
    public var macdIndicator: TALibIndicatorProvider.MacdIndicator!
    
    @EditableProperty
    public var histogram: HistogramFinanceSeries!
    
    @EditableProperty
    public var macd: LineFinanceSeries!
    
    @EditableProperty
    public var signal: LineFinanceSeries!
    
    public init(
        pane: PaneId,
        id: StudyId = StudyId.uniqueId(name: "MACD"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        yValuesId: DataSourceId = DataSourceId.DEFAULT_Y_VALUES_ID
    ) {
        macdId = DataSourceId.uniqueId(studyId: id, name: "MACD")
        macdSignalId = DataSourceId.uniqueId(studyId: id, name: "MACD_signal")
        macdHistId = DataSourceId.uniqueId(studyId: id, name: "MACD_hist")
        
        super.init(id: id, pane: pane)
        
        macdIndicator = TALibIndicatorProvider.MacdIndicator(
            inputId: yValuesId,
            macdId: macdId,
            macdSignalId: macdSignalId,
            macdHistId: macdHistId,
            slow: Constants.Indicator.defaultSlow,
            fast: Constants.Indicator.defaultFast,
            signal: Constants.Indicator.defaultSignal
        )
        indicators.add(macdIndicator)
        
        histogram = HistogramFinanceSeries(
            name: FinanceString.macdHistogramId.name,
            xValues: xValuesId,
            yValues: macdIndicator.macdHistId,
            yAxisId: yAxisId
        )
        
        macd = LineFinanceSeries(
            name: FinanceString.macdId.name,
            xValues: xValuesId,
            yValues: macdIndicator.macdId,
            yAxisId: self.yAxisId
        )
        
        signal = LineFinanceSeries(
            name: FinanceString.macdSignalId.name,
            xValues: xValuesId,
            yValues: macdIndicator.macdSignalId,
            yAxisId: self.yAxisId
        )
        signal.strokeStyle.updateInitialValue(SCISolidPenStyle(color: Colors.defaultRed, thickness: Colors.defaultThickness))
        
        financeSeries.add(histogram)
        financeSeries.add(macd)
        financeSeries.add(signal)
    }
    
    public override func reset() {
        super.reset()

        macdIndicator.reset()
        histogram.reset()
        macd.reset()
        signal.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return editable !== macdIndicator.input
    }
    
    public override var title: String {
        guard let input = macdIndicator.input?.value,
              let slow = macdIndicator.slow?.value,
              let fast = macdIndicator.fast?.value,
              let signal = macdIndicator.signal?.value
        else {
            return "MACD"
        }
        return "MACD(\(input) \(slow) \(fast) \(signal))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return MacdTooltip(study: self)
    }
    
    public class MacdTooltip: StudyTooltipBase<MacdStudy> {
        private let macdSeriesTooltip: ISCISeriesTooltip
        private let signalSeriesTooltip: ISCISeriesTooltip
        private let histogramSeriesTooltip: ISCISeriesTooltip
        
        public init(study: MacdStudy) {
            self.macdSeriesTooltip = study.macd.getTooltip()
            self.signalSeriesTooltip = study.signal.getTooltip()
            self.histogramSeriesTooltip = study.histogram.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)

            if showSeriesTooltips {
                macdSeriesTooltip.place(into: self)
                signalSeriesTooltip.place(into: self)
                histogramSeriesTooltip.place(into: self)
            } else {
                macdSeriesTooltip.remove(from: self)
                signalSeriesTooltip.remove(from: self)
                histogramSeriesTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: macdSeriesTooltip, point: point)
            tryUpdate(tooltip: signalSeriesTooltip, point: point)
            tryUpdate(tooltip: histogramSeriesTooltip, point: point)
        }
    }
}
