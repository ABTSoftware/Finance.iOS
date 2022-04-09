//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// IGradientView.swift is part of SCICHART®, High Performance Scientific Charts
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

/*
 * You must override `class var layerClass: AnyClass` and `return CAGradientLayer.self in order to configure gradient layer
 **/
public protocol IGradientView where Self: UIView {
    func configureGradientLayer(colors: [UIColor])
}

public extension IGradientView {
    func configureGradientLayer(colors: [UIColor]) {
        let gradientLayer = self.layer as? CAGradientLayer
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer?.colors = colors.map { $0.cgColor }
    }
}
