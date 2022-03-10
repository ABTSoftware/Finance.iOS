//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// Double+Extension.swift is part of SCICHART®, High Performance Scientific Charts
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

private let priceFormatter = PriceFormatter()

public extension Double {
    func formattedPrice(format: String) -> String {
        return priceFormatter.getFormattedValue(value: self, format: format) ?? ""
    }
    
    var fractionZerosCount: Int {
        if (self == 0.0) { return 0 }
        
        return Int(max(-floor(log(self) / log(10.0) + 1.0), 0.0))
    }
}
