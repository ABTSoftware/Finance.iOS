//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// PenStyleEditableProperty.swift is part of SCICHART®, High Performance Scientific Charts
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

import SciChart

public class SolidPenStyle: SCISolidPenStyle {
    public init(color: UIColor, thickness: Float, strokeDashType: StrokeDashType) {
        super.init(__colorCode: color.colorARGBCode(), thickness: thickness, strokeDashArray: strokeDashType.value, antiAliasing: true)
    }
}

public class PenStyleEditableProperty: EditablePropertyBase<SCIPenStyle> {
    public init(name: String, parentName: String, initialValue: SCIPenStyle, listener: @escaping (PropertyId, SCIPenStyle) -> Void) {
        super.init(name: name, parentName: parentName, viewType: .penStyleProperty, initialValue: initialValue, listener: listener)
    }
    
    public var strokeDashType: StrokeDashType {
        return StrokeDashType.getType(strokeDashArray: value.strokeDashArray)
    }
    
    public override func isValidValue(_ value: SCIPenStyle) -> SetPropertyResult {
        if value.thickness > 0 {
            return .success
        } else {
            return .fail("Expected value greater then 0")
        }
    }
}

public enum StrokeDashType: String, CaseIterable {
    case solidLine
    case dashMini
    case dashMiddle
    case dashLarge
    
    var value: [NSNumber] {
        switch self {
        case .solidLine: return [10, 0]
        case .dashMini: return [3, 3]
        case .dashMiddle: return [7, 7]
        case .dashLarge: return [15, 15]
        }
    }
    
    static func getType(strokeDashArray: [NSNumber]?) -> StrokeDashType {
        return self.allCases.filter({ strokeDashArray == $0.value }).first ?? .solidLine
    }
}
