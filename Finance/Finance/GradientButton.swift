//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// GradientButton.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import UIKit

open class GradientButton: UIButton, IGradientView {
    
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private let normalColors: [UIColor]
    private let selectedColors: [UIColor]

    public init(normalColors: [UIColor], selectedColors: [UIColor]) {
        self.normalColors = normalColors
        self.selectedColors = selectedColors
        
        super.init(frame: .zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var isSelected: Bool {
        didSet {
            onSelectionChanged()
        }
    }
    
    open func onSelectionChanged() {
        isSelected ? configureGradientLayer(colors: selectedColors) : configureGradientLayer(colors: normalColors)
    }
}
