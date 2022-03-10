//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// ShiftCrosshairHelper.swift is part of SCICHART®, High Performance Scientific Charts
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
import CoreGraphics

class ShiftCrosshairHelper {
    var lastUpdatedPoint = CGPoint.zero
    var lastTouchPoint = CGPoint(x: CGFloat.nan, y: CGFloat.nan)
    
    private var lastPointHeightPercent: CGFloat?
    private var lastPointWidthPercent: CGFloat?
    
    private weak var surface: ISCIChartSurface?
    
    init(surface: ISCIChartSurface) {
        self.surface = surface
    }
    
    func updateArgsLocation(args: SCIGestureModifierEventArgs) {
        guard let _ = args.gestureRecognizer,
              let view = surface?.renderableSeriesArea.view
        else { return }
        
        let deltaLocation = getDelta(location: args.location)
        
        lastTouchPoint = args.location
        
        var newX = lastUpdatedPoint.x + deltaLocation.x
        var newY = lastUpdatedPoint.y + deltaLocation.y
        
        if newX > view.frame.maxX {
            newX = view.frame.maxX
        } else if newX < view.frame.minX {
            newX = view.frame.minX
        }
        
        if newY > view.frame.maxY {
            newY = view.frame.maxY
        } else if newY < view.frame.minY {
            newY = view.frame.minY
        }

        if args.isMaster {
            args.location = CGPoint(x: newX, y: newY)
        }
        
        lastUpdatedPoint = args.location
        
        lastPointWidthPercent = args.location.x / view.frame.maxX
        lastPointHeightPercent = args.location.y / view.frame.maxY
    }
    
    func normilizeLastUpdatedPoint() {
        guard
            let view = surface?.renderableSeriesArea.view,
            let lastPointHeightPercent = lastPointHeightPercent,
            let lastPointWidthPercent = lastPointWidthPercent
        else { return }
        
        lastUpdatedPoint = CGPoint(
            x: view.frame.maxX * lastPointWidthPercent,
            y: view.frame.maxY * lastPointHeightPercent
        )
    }
        
    private func getDelta(location: CGPoint) -> CGPoint {
        let result = CGPoint(x: location.x - lastTouchPoint.x, y: location.y - lastTouchPoint.y)
                
        if abs(result.x) < CGFloat.ulpOfOne && abs(result.y) < CGFloat.ulpOfOne { return .zero }

        return result
    }
}
