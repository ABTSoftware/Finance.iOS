//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2022. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// Candlestick.swift is part of the SCICHART® FinanceLibDemo App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® FinanceLibDemo App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import Foundation

struct Candlestick {
    let openTime: Double
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    
    let symbol: String
    
    init(dto: BinanceCandlestickDTO, symbol: String = "BTCUSDT") {
        self.openTime = dto.openTime / 1000
        self.open = Double(dto.open) ?? 0
        self.high = Double(dto.high) ?? 0
        self.low = Double(dto.low) ?? 0
        self.close = Double(dto.close) ?? 0
        self.volume = Double(dto.assetVolume) ?? 0
        
        self.symbol = symbol
    }
}

struct BinanceCandlestickDTO: Decodable {
    let openTime: Double
    let open: String
    let high: String
    let low: String
    let close: String
    let assetVolume: String
    let closeTime: Double
    let quoteVolume: String
    let trades: UInt64
    let buyAssetVolume: String
    let buyQuoteVolume: String
    let ignored: String?
    
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        self.openTime = try values.decode(Double.self)
        self.open = try values.decode(String.self)
        self.high = try values.decode(String.self)
        self.low = try values.decode(String.self)
        self.close = try values.decode(String.self)
        self.assetVolume = try values.decode(String.self)
        self.closeTime = try values.decode(Double.self)
        self.quoteVolume = try values.decode(String.self)
        self.trades = try values.decode(UInt64.self)
        self.buyAssetVolume = try values.decode(String.self)
        self.buyQuoteVolume = try values.decode(String.self)
        self.ignored = try values.decodeIfPresent(String.self)
    }
}
