//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// CursorCrossHairDrawableBehaviour.swift is part of SCICHART®, High Performance Scientific Charts
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

import SciChart.Protected.SCIDrawableBehavior

class CursorCrossHairDrawableBehaviour: SCIDrawableBehavior<ISCIChartModifierCore> {
    override func onDraw(_ rect: CGRect) {
        guard
            isLastPointValid,
            let modifier = modifier as? CrosshairModifier,
            let ctx = UIGraphicsGetCurrentContext()
        else {
            return
        }
        
        let x = self.lastUpdateArgs.location.x
        let y = self.lastUpdateArgs.location.y
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: rect.size.height))
        
        if self.lastUpdateArgs.isMaster {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.size.width, y: y))
        }
        
        let style = modifier.crosshairPenStyle
        style.paint.draw(path.cgPath, with: ctx, in: rect)
    }
}
