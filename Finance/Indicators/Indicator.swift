//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// Indicator.swift is part of the SCICHART® SciTraider App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTraider App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import Foundation

public enum Indicator: String, Codable, CaseIterable {
    case MACD
    case SMA
    case BBANDS
    case RSI
    case ADX
    case ATR
    case CCI
    case EMA
    case OBV
    case SAR
    case STDDEV
    case STOCH
    case HT_TRENDLINE
    
    public var title: String {
        switch self {
        case .MACD: return "\(rawValue) / Moving Average Convergence/Divergence"
        case .SMA: return "\(rawValue) / Simple Moving Average"
        case .BBANDS: return "\(rawValue) / Bollinger Bands"
        case .RSI: return "\(rawValue) / Relative Strength Index"
        case .ADX: return "\(rawValue) / Average Directional Movement Index"
        case .ATR: return "\(rawValue) / Average True Range"
        case .CCI: return "\(rawValue) / Commodity Channel Index"
        case .EMA: return "\(rawValue) / Exponential Moving Average"
        case .OBV: return "\(rawValue) / On Balance Volume"
        case .SAR: return "\(rawValue) / Parabolic SAR"
        case .STDDEV: return "\(rawValue) / Standard Deviation"
        case .STOCH: return "\(rawValue) / Stochastic"
        case .HT_TRENDLINE: return "\(rawValue) / Hilbert Transform - Instantaneous Trendline"
        }
    }
    
    public var needsSeparatePane: Bool {
        switch self {
        case .SMA, .BBANDS, .EMA, .SAR, .HT_TRENDLINE: return false
        default: return true
        }
    }
}
