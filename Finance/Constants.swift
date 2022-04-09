//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// Constants.swift is part of SCICHART®, High Performance Scientific Charts
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

public enum Constants {    
    public static let viewForDetectResizingHeight: CGFloat = 10
    public static let separatorNotActiveHeight: CGFloat = 1
    public static let separatorActiveHeight: CGFloat = 2
    public static let minimumMainPaneHeight: CGFloat = 40
    public static let minimumSecondaryPaneHeight: CGFloat = 50
    public static let defaultSecondaryPaneHeightRatio: CGFloat = 7
    
    public static let legendTooltipTitleColor = UIColor.white
    public static let defaultTooltipTitleFontStyle = SCIFontStyle(fontDescriptor: UIFont.systemFont(ofSize: 12, weight: .semibold).fontDescriptor, andTextColor: legendTooltipTitleColor)
    public static let defaultTooltipInfoFontStyle = SCIFontStyle(fontDescriptor: UIFont.systemFont(ofSize: 12, weight: .regular).fontDescriptor, andTextColor: legendTooltipTitleColor)
    
    public enum Indicator {
        public static let defaultPeriod: Int = 14
        public static let defaultDev: Double = 2.0
        public static let defaultSlow: Int = 12
        public static let defaultFast: Int = 26
        public static let defaultSignal: Int = 9
        public static let defaultAcceleration: Double = 1.0
        public static let defaultDataPointWidth: Double = 0.7
        public static let defaultMaximum: Double = 1.0
        public static let defaultMaType: TA_MAType_Option = .sma
        
        public static let defaultThickness: Float = 2.0
        public static let lightThickness: Float = 1.0
        public static let defaultOpacity: Float = 1.0
    }
}
