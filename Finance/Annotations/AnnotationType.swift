//******************************************************************************
// SCICHARTÂ® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// AnnotationType.swift is part of the SCICHARTÂ® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHARTÂ® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart

public enum AnnotationType: CaseIterable {
    case horizontalLine, arrow, box, text
    
    public var icon: String {
        switch self {
        case .horizontalLine: return "minus"
        case .arrow: return "arrow.up.right"
        case .box: return "square"
        case .text: return "a"
        }
    }
}
