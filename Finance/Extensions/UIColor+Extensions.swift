//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// UIColor+Extensions.swift is part of SCICHART®, High Performance Scientific Charts
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

import UIKit

public enum Colors {
    public static let defaultCandleStickDataPointWidth: Double = 0.7
    public static let ohlcLegendUpColor = UIColor.fromARGBColorCode(Colors.defaultStrokeUp)
    public static let ohlcLegendDownColor = UIColor.fromARGBColorCode(Colors.defaultStrokeDown)
    public static let defaultLegendValueColor = UIColor.fromARGBColorCode(0xFF4DB7F3)
    
    public static let defaultRed: UInt32 = 0xFFFD3720
    public static let defaultGreen: UInt32 = 0xFF28996F
    public static let defaultBlue: UInt32 = 0xFF4DB7F3
    
    public static let defaultBand = UIColor.argb(defaultBlue, withOpacity: 0.15)
    
    public static let defaultStrokeUp: UInt32 = defaultGreen
    public static let defaultStrokeDown: UInt32 = defaultRed
    public static let defaultFillUp: UInt32 = UIColor.argb(defaultStrokeUp, withOpacity: 0.7)
    public static let defaultFillDown: UInt32 = UIColor.argb(defaultStrokeDown, withOpacity: 0.7)
    
    public static let defaultThickness: Float = 2
    public static let lightThickness: Float = 1
    
    public static let mainButtonStart: UInt32 = 0xFF9494CD
    public static let mainButtonEnd: UInt32 = 0xFF505090
    public static let secondaryButtonStart: UInt32 = 0xFF404558
    public static let secondaryButtonEnd: UInt32 = 0xFF2C2E3A
    
    public static let line: UInt32 = 0xFF78809D
    public static let separatorLine: UInt32 = 0xFF2D2A3C
    public static let secondaryBackground: UInt32 = 0xFF454A5E
}

public extension UIColor {
    static let fillUp = UIColor.fromARGBColorCode(Colors.defaultStrokeUp)
    static let fillDown = UIColor.fromARGBColorCode(Colors.defaultStrokeDown)
    
    static let mainButtonStart = UIColor.fromARGBColorCode(Colors.mainButtonStart)
    static let mainButtonEnd = UIColor.fromARGBColorCode(Colors.mainButtonEnd)
    
    static let secondaryButtonStart = UIColor.fromARGBColorCode(Colors.secondaryButtonStart)
    static let secondaryButtonEnd = UIColor.fromARGBColorCode(Colors.secondaryButtonEnd)
    
    static let line = UIColor.fromARGBColorCode(Colors.line)
    static let separatorLine = UIColor.fromARGBColorCode(Colors.separatorLine)
    static let resizingLine = UIColor.fromARGBColorCode(Colors.mainButtonStart)
    static let secondaryBackground = UIColor.fromARGBColorCode(Colors.secondaryBackground)
}
