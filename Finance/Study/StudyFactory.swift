//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// StudyFactory.swift is part of the SCICHART® SciTraider App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTraider App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import Foundation

public class StudyFactory : IStudyFactory {
    public init() {}
    
    public func createDefaultIndicatorStudyFor(indicator: Indicator) -> IStudy {
        
        let paneId = indicator.needsSeparatePane ? PaneId.uniqueId(name: indicator.rawValue) : PaneId.DEFAULT_PANE
        switch indicator {
        case .MACD:
            return MacdStudy(pane: paneId)
        case .SMA:
            return SMAStudy(pane: paneId)
        case .BBANDS:
            return BBandsStudy(pane: paneId)
        case .RSI:
            return RSIStudy(pane: paneId)
        case .ADX:
            return ADXStudy(pane: paneId)
        case .ATR:
            return ATRStudy(pane: paneId)
        case .CCI:
            return CCIStudy(pane: paneId)
        case .EMA:
            return EMAStudy(pane: paneId)
        case .OBV:
            return OBVStudy(pane: paneId)
        case .SAR:
            return SARStudy(pane: paneId)
        case .STDDEV:
            return STDDevStudy(pane: paneId)
        case .STOCH:
            return StochStudy(pane: paneId)
        case .HT_TRENDLINE:
            return HT_TrendlineStudy(pane: paneId)
        }
    }
    
    public func restoreIndicatorStudyFromState(studyState: IndicatorStudyState) -> IStudy {
        var study: IStudy!
        
        switch studyState.indicator {
        case .MACD:
            study = MacdStudy(pane: studyState.paneId, id: studyState.studyId)
        case .SMA:
            study = SMAStudy(pane: studyState.paneId, id: studyState.studyId)
        case .BBANDS:
            study = BBandsStudy(pane: studyState.paneId, id: studyState.studyId)
        case .RSI:
            study = RSIStudy(pane: studyState.paneId, id: studyState.studyId)
        case .ADX:
            study = ADXStudy(pane: studyState.paneId, id: studyState.studyId)
        case .ATR:
            study = ATRStudy(pane: studyState.paneId, id: studyState.studyId)
        case .CCI:
            study = CCIStudy(pane: studyState.paneId, id: studyState.studyId)
        case .EMA:
            study = EMAStudy(pane: studyState.paneId, id: studyState.studyId)
        case .OBV:
            study = OBVStudy(pane: studyState.paneId, id: studyState.studyId)
        case .SAR:
            study = SARStudy(pane: studyState.paneId, id: studyState.studyId)
        case .STDDEV:
            study = STDDevStudy(pane: studyState.paneId, id: studyState.studyId)
        case .STOCH:
            study = StochStudy(pane: studyState.paneId, id: studyState.studyId)
        case .HT_TRENDLINE:
            study = HT_TrendlineStudy(pane: studyState.paneId, id: studyState.studyId)
        }
        study.restorePropertyStateFrom(state: studyState.properties)
        
        return study
    }
    
    public func saveIndicatorStudyState(study: IStudy) -> IndicatorStudyState {
        var _indicator: Indicator?
        
        if study is RSIStudy {
            _indicator = .RSI
        }
        
        if study is BBandsStudy {
            _indicator = .BBANDS
        }
        
        if study is MacdStudy {
            _indicator = .MACD
        }
        
        if study is SMAStudy {
            _indicator = .SMA
        }
        
        if study is ADXStudy {
            _indicator = .ADX
        }
        
        if study is ATRStudy {
            _indicator = .ATR
        }
        
        if study is CCIStudy {
            _indicator = .CCI
        }
        
        if study is EMAStudy {
            _indicator = .EMA
        }
        
        if study is OBVStudy {
            _indicator = .OBV
        }
        
        if study is SARStudy {
            _indicator = .SAR
        }
        
        if study is STDDevStudy {
            _indicator = .STDDEV
        }
        
        if study is StochStudy {
            _indicator = .STOCH
        }
        
        if study is HT_TrendlineStudy {
            _indicator = .HT_TRENDLINE
        }
        
        guard let indicator = _indicator else {
            fatalError("Can't save IndicatorStudyState")
        }
        return IndicatorStudyState(indicator: indicator, paneId: study.pane, studyId: study.id, properties: study.toProperties())
    }
    
    public func restorePriceSeriesStudyFromState(state: PriceSeriesStudyState) -> PriceSeriesStudy {
        let seriesStudy = PriceSeriesStudy(pane: state.paneId, id: state.studyId)
        seriesStudy.restorePropertyStateFrom(state: state.properties)
        
        return seriesStudy
    }
    
    public func savePriceSeriesStudyState(study: PriceSeriesStudy) -> PriceSeriesStudyState {
        return PriceSeriesStudyState(paneId: study.pane, studyId: study.id, properties: study.toProperties())
    }
}

extension IStudy {
    func toProperties() -> EditablePropertyState {
        let state = EditablePropertyState()
        self.savePropertyStateTo(state: state)
        
        return state
    }
}
