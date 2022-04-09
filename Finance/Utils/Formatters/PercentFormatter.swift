//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// PercentFormatter.swift is part of the SCICHART® SciTraider App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTraider App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import Foundation

public class PercentFormatter: NumberFormatter {
    public override init() {
        super.init()
        
        numberStyle = .percent
        minimumFractionDigits = 2
        positivePrefix = plusSign
        negativePrefix = minusSign
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func string(from value: Double) -> String? {
        return string(from: NSNumber(value: value / 100))
    }
}
