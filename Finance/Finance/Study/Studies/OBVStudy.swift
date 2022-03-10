//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// OBVStudy.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public class OBVStudy: CandleStudyBase {
    private let obvOutputId: DataSourceId
    
    @EditableProperty
    public var obvIndicator: TALibIndicatorProvider.OBVIndicator!
    
    @EditableProperty
    public var obvSeries: LineFinanceSeries!
    
    public init(
        pane: PaneId,
        id: StudyId = StudyId.uniqueId(name: "OBV"),
        xValuesId: DataSourceId = DataSourceId.DEFAULT_X_VALUES_ID,
        closeValuesId: DataSourceId = DataSourceId.DEFAULT_CLOSE_VALUES_ID,
        volumeValuesId: DataSourceId = DataSourceId.DEFAULT_VOLUME_VALUES_ID
    ) {
        obvOutputId = DataSourceId.uniqueId(studyId: id, name: "OBV")
        
        super.init(id: id, pane: pane)
        
        obvIndicator = TALibIndicatorProvider.OBVIndicator(
            inputCloseId: closeValuesId,
            inputVolumeId: volumeValuesId,
            outputId: obvOutputId
        )
        indicators.add(obvIndicator)
        
        obvSeries = LineFinanceSeries(
            name: FinanceString.rsiIndicatorName.name,
            xValues: xValuesId,
            yValues: obvIndicator.outputId,
            yAxisId: self.yAxisId
        )
        financeSeries.add(obvSeries)
    }
    
    public override func reset() {
        super.reset()

        obvIndicator.reset()
        obvSeries.reset()
    }
    
    public override func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return
            editable !== obvIndicator.inputClose &&
            editable !== obvIndicator.inputVolume
    }
    
    public override var title: String {
        guard
            let inputClose = obvIndicator.inputClose?.value,
            let inputVolume = obvIndicator.inputVolume?.value
        else {
            return "OBV"
        }
        return "OBV(\(inputClose) \(inputVolume))"
    }
    
    public override func getStudyTooltip() -> IStudyTooltip {
        return OBVTooltip(study: self)
    }
    
    public class OBVTooltip: StudyTooltipBase<OBVStudy> {
        private let obvSeriesTooltip: ISCISeriesTooltip
        
        public init(study: OBVStudy) {
            obvSeriesTooltip = study.obvSeries.getTooltip()
            
            super.init(study: study)
            
            self.axis = .horizontal
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
            super.onShowSeriesTooltipsChanged(showSeriesTooltips: showSeriesTooltips)
            
            if showSeriesTooltips {
                obvSeriesTooltip.place(into: self)
            } else {
                obvSeriesTooltip.remove(from: self)
            }
        }
        
        public override func update(point: CGPoint) {
            super.update(point: point)
            
            tryUpdate(tooltip: obvSeriesTooltip, point: point)
        }
    }
}
