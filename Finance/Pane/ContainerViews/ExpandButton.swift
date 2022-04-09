//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// ExpandButton.swift is part of SCICHART®, High Performance Scientific Charts
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

open class ExpandButton: ChartButton {
    
    public init() {
        super.init(image: .Expand)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func updateIcon(_ isExpanded: Bool) {
        setImageForNormalState(isExpanded ? UIImage.Collapse : UIImage.Expand)
    }
    
    open func updateIsEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        alpha = isEnabled ? 1 : 0.3
    }
}
