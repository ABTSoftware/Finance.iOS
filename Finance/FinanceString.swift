//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FinanceString.swift is part of SCICHART®, High Performance Scientific Charts
// For full terms and conditions of the license, see http://www.scichart.com/scichart-eula/
//
// This source code is protected by international copyright law. Unauthorized
// reproduction, reverse-engineering, or distribution of all or any portion of
// this source code is strictly prohibited.
//
// This source code contains confidential and proprietary trade secrets of
// SciChart Ltd., and should at no time be copied, transferred, sold,
// distributed or made available without express written permission.
//******************************************************************************

import Foundation

public enum FinanceString {
    //    <!-- OHLCV values IDs -->
    case xValuesId
    case openValuesId
    case highValuesId
    case lowValuesId
    case closeValuesId
    case volumeValuesId
    
    //    <!-- Indicator values IDs -->
    case rsiId
    case smaId
    
    case macdId
    case macdHistogramId
    case macdSignalId
    
    case bBandsBandId
    case bBandsMidId
    case stochSlowKId
    case stochSlowDId
    
    //    <!-- Indicator Names -->
    case macdIndicatorName
    case rsiIndicatorName
    case smaIndicatorName
    case bBandsIndicatorName
    case htTrendlineIndicatorName
    case stdDevIndicatorName
    case emaIndicatorName
    case stochIndicatorName
    case adxIndicatorName
    case atrIndicatorName
    case cciIndicatorName
    case obvIndicatorName
    case sarIndicatorName
    
    //    <!-- Property Names -->
    case financeSeriesOpacity
    
    case strokeStyle
    case fillStyle
    case dataPointWidth
    
    case arrowHeadStyle
    case fontStyle
    case textStyle
    case lineAnnotation
    case boxAnnotation
    case arrowAnnotation
    case textAnnotation
    case coordinates
    
    case bandsY1StrokeStyle
    case bandsY1FillStyle
    
    case candlestickStrokeUpStyle
    case candlestickStrokeDownStyle
    case candlestickFillUpStyle
    case candlestickFillDownStyle
    
    case histogramFillUpStyle
    case histogramFillDownStyle
    
    case xValues
    case yValues
    case y1Values
    case openValues
    case highValues
    case lowValues
    case closeValues
    case indicatorSingleInput
    case indicatorHighInput
    case indicatorLowInput
    case indicatorCloseInput
    case indicatorVolumeInput
    
    case indicatorSmaPeriod
    case indicatorRsiPeriod
    case indicatorAdxPeriod
    case indicatorAtrPeriod
    case indicatorCciPeriod
    case indicatorEmaPeriod
    case indicatorMacdSlow
    case indicatorMacdFast
    case indicatorMacdSignal
    case indicatorBBandsPeriod
    case indicatorBBandsDevUp
    case indicatorBBandsDevDown
    case indicatorBBandsMAType
    case indicatorStdDevPeriod
    case indicatorStdDev_Dev
    case indicatorStochFastK
    case indicatorStochSlowK
    case indicatorStochSlowD
    case indicatorStochSlowK_MAType
    case indicatorStochSlowD_MAType
    case indicatorSarAcceleration
    case indicatorSarMaximum
    
    case defaultYAxis
    case textFormattingAxis
    case cursorTextFormattingAxis
    
    case studyPriceSeries
    case studyVolumeSeries
    case studyVolumeYAxis
    
    public var name: String {
        switch self {
            case .xValuesId: return "XValues"
            case .openValuesId: return "openValues"
            case .highValuesId: return "highValues"
            case .lowValuesId: return "lowValues"
            case .closeValuesId: return "closeValues"
            case .volumeValuesId: return "volumeValues"
            case .rsiId: return "RSI"
            case .smaId: return "SMA"
            case .macdId: return "MACD"
            case .macdHistogramId: return "MACD Histogram"
            case .macdSignalId: return "MACD Signal"
            case .bBandsBandId: return "BBands Band"
            case .bBandsMidId: return "BBands Mid"
            case .stochSlowKId: return "Slow K"
            case .stochSlowDId: return "Slow D"
            case .macdIndicatorName: return "MACD"
            case .rsiIndicatorName: return "RSI"
            case .smaIndicatorName: return "SMA"
            case .bBandsIndicatorName: return "BBands"
            case .htTrendlineIndicatorName: return "HT_TRENDLINE"
            case .stdDevIndicatorName: return "STDDEV"
            case .emaIndicatorName: return "EMA"
            case .stochIndicatorName: return "STOCH"
            case .adxIndicatorName: return "ADX"
            case .atrIndicatorName: return "ATR"
            case .cciIndicatorName: return "CCI"
            case .obvIndicatorName: return "OBV"
            case .sarIndicatorName: return "SAR"
            case .financeSeriesOpacity: return "Opacity"
            case .strokeStyle: return "Stroke"
            case .fillStyle: return "Fill"
            case .dataPointWidth: return "Data Point Width"
            case .arrowHeadStyle: return "Arrow head"
            case .fontStyle: return "Font"
            case .textStyle: return "Text"
            case .lineAnnotation: return "Line annotation"
            case .boxAnnotation: return "Box annotation"
            case .arrowAnnotation: return "Arrow annotation"
            case .textAnnotation: return "Text annotation"
            case .coordinates: return "Coordinates annotation"
            case .bandsY1StrokeStyle: return "Y1 Stroke"
            case .bandsY1FillStyle: return "Y1 Fill"
            case .candlestickStrokeUpStyle: return "Stroke Up"
            case .candlestickStrokeDownStyle: return "Stroke Down"
            case .candlestickFillUpStyle: return "Fill Up"
            case .candlestickFillDownStyle: return "Fill Down"
            case .histogramFillUpStyle: return "Fill Up"
            case .histogramFillDownStyle: return "Fill Down"
            case .xValues: return "X Values"
            case .yValues: return "Y Values"
            case .y1Values: return "Y1 Values"
            case .openValues: return "Open Values"
            case .highValues: return "High Values"
            case .lowValues: return "Low Values"
            case .closeValues: return "Close Values"
            case .indicatorSingleInput: return "Input"
            case .indicatorHighInput: return "Input"
            case .indicatorLowInput: return "Input"
            case .indicatorCloseInput: return "Input"
            case .indicatorVolumeInput: return "Input"
            case .indicatorSmaPeriod: return "Period"
            case .indicatorRsiPeriod: return "Period"
            case .indicatorAdxPeriod: return "Period"
            case .indicatorAtrPeriod: return "Period"
            case .indicatorCciPeriod: return "Period"
            case .indicatorEmaPeriod: return "Period"
            case .indicatorMacdSlow: return "Slow"
            case .indicatorMacdFast: return "Fast"
            case .indicatorMacdSignal: return "Signal"
            case .indicatorBBandsPeriod: return "Period"
            case .indicatorBBandsDevUp: return "Dev Up"
            case .indicatorBBandsDevDown: return "Dev Down"
            case .indicatorBBandsMAType: return "MA Type"
            case .indicatorStdDevPeriod: return "Period"
            case .indicatorStdDev_Dev: return "Dev"
            case .indicatorStochFastK: return "FastK"
            case .indicatorStochSlowK: return "SlowK"
            case .indicatorStochSlowD: return "SlowD"
            case .indicatorStochSlowK_MAType: return "SlowK MAType"
            case .indicatorStochSlowD_MAType: return "SlowD MAType"
            case .indicatorSarAcceleration: return "Acceleration"
            case .indicatorSarMaximum: return "Maximum"
            case .defaultYAxis: return "YAxis"
            case .textFormattingAxis: return "Text Formatting"
            case .cursorTextFormattingAxis: return "Cursor Text Formatting"
            case .studyPriceSeries: return "Prices"
            case .studyVolumeSeries: return "Volume"
            case .studyVolumeYAxis: return "Volume Axis"
        }
    }
}
