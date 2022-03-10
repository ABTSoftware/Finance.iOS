//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FinanceYAxisDragModifier.swift is part of SCICHART®, High Performance Scientific Charts
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

import SciChart.Protected.SCIAxisDragModifierBase

open class FinanceYAxisDragModifier: SCIYAxisDragModifier {
    
    open var excludeAxisIds: [AxisId] = []
    
    public let yAutoRangeButton: YAutoRangeButton
    
    open var yAutoRange = SCIAutoRange.always {
        didSet {
            updateYAutoRange()
        }
    }
    
    public init(autoRangeButton: YAutoRangeButton) {
        self.yAutoRangeButton = autoRangeButton
        
        super.init(defaultNumberOfTouches: 1)
        
        autoRangeButton.action = { [weak self] in
            guard let self = self else { return }
            
            self.onAutoButtonPressed()
            self.yAutoRangeButton.selectionHapticFeedback()
        }
        
        autoRangeButton.updateState(yAutoRange)
    }
    
    open override var applicableAxes: SCIAxisCollection {
        let yAxes = self.yAxes.toArray().filter({ !excludeAxisIds.map { $0.description }.contains($0.axisId) })
        
        return SCIAxisCollection(collection: yAxes)
    }
    
    open override func applyScale(to applyTo: ISCIRange, xDelta: CGFloat, yDelta: CGFloat, isSecondHalf: Bool, axis: ISCIAxis) {
        
        if self.yAutoRange != .never {
            self.yAutoRange = .never
        }
        
        let interactivityHelper = axis.currentInteractivityHelper
        
        let pixelsToScroll = axis.isHorizontalAxis ? -xDelta : -yDelta
        
        interactivityHelper.scroll(inMaxDirection: applyTo, byPixels: pixelsToScroll)
        interactivityHelper.scroll(inMinDirection: applyTo, byPixels: -pixelsToScroll)
        
        if let visibleRangeLimit = axis.visibleRangeLimit {
            applyTo.clip(to: visibleRangeLimit, clipMode: axis.visibleRangeLimitMode)
        }
    }
    
    private func updateYAutoRange() {
        for i in 0 ..< applicableAxes.count {
            applicableAxes[i].autoRange = yAutoRange
        }
        
        yAutoRangeButton.updateState(yAutoRange)
    }
    
    private func onAutoButtonPressed() {
        guard let parentSurface = parentSurface else {
            return
        }
        
        if yAutoRangeButton.isSelected {
            let duration = 0.2
            parentSurface.animateZoomExtentsY(withDuration: duration)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                self?.yAutoRange = .always
            }
        } else {
            self.yAutoRange = .never
        }
    }
}
