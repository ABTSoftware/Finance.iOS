//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FinanceAxisTooltipBase.swift is part of SCICHART®, High Performance Scientific Charts
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

import SciChart.Protected.SCIAxisTooltip

class FinanceAxisTooltipBase: SCIAxisTooltip {
    
    var horizontalPadding: CGFloat { 0 }
    var verticalPadding: CGFloat { 5 }
    
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: superSize.width + horizontalPadding * 2, height: superSize.height + verticalPadding * 2)
    }
    
    override func updateInternal(with axisInfo: SCIAxisInfo) -> Bool {
        text = "\(axisInfo.cursorFormattedDataValue.rawString)"
        font = .systemFont(ofSize: 10, weight: .medium)
        textColor = .white
        textAlignment = .center
        
        setTooltipBackground(Colors.secondaryBackground)
        
        return true
    }
    
    override func update(action updateAction: @escaping SCIUpdateAxisTooltipAction) {
        super.update(action: updateAction)

        preventTooltipFromClipping()
    }
    
    func preventTooltipFromClipping() {
        fatalError("Must be implemented in subclasses")
    }
}
