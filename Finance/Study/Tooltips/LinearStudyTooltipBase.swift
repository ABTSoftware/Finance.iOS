//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// LinearStudyTooltipBase.swift is part of SCICHART®, High Performance Scientific Charts
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

open class LinearStudyTooltipBase<TStudy: IStudy>: StackViewContainer, IStudyTooltip {
    public let study: TStudy
    
    open var useInterpolation: Bool = false
    
    private let hitTestInfo = SCIHitTestInfo()
    
    public init(study: TStudy) {
        self.study = study

        super.init(frame: .zero)
        
        axis = .vertical
        alignment = .leading
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var studyId: StudyId {
        return study.id
    }
    
    private var _showSeriesTooltips = false
    open var showSeriesTooltips: Bool {
        get {
            _showSeriesTooltips
        }
        
        set {
            _showSeriesTooltips = newValue
            onShowSeriesTooltipsChanged(showSeriesTooltips: newValue)
        }
    }
    
    open func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {
        fatalError("Must be implemented in subclasses")
    }
    
    open func update() {
        fatalError("Must be implemented in subclasses")
    }
    
    open func update(point: CGPoint) {
        fatalError("Must be implemented in subclasses")
    }
    
    open func place(into viewContainer: ISCIViewContainer) {
        viewContainer.safeAdd(self)
    }
    
    open func remove(from viewContainer: ISCIViewContainer) {
        viewContainer.safeRemove(self)
    }
    
    @discardableResult
    open func tryUpdate(tooltip: ISCIHitTestInfoUpdatable, point: CGPoint) -> Bool {
        let rs = tooltip.renderableSeries
        
        if isSeriesValid(series: rs) {
            // need to prevent updates of data series and render pass data during hit test and update of series info
            let dataSeriesLock = rs.dataSeriesLock
            let renderPassDataLock = rs.renderPassDataLock
            
            defer {
                renderPassDataLock.readUnlock()
                dataSeriesLock.readUnlock()
            }

            // SC_DROID-391: need to lock in this specific order to prevent deadlock
            dataSeriesLock.readLock()
            renderPassDataLock.readLock()
            updateHitTestInfo(hitTestInfo: hitTestInfo, rs: rs, point: point)
            if isHitPointValid(hitTestInfo: hitTestInfo) {
                tooltip.update(hitTestInfo, interpolate: useInterpolation)
                return true
            }
        }
        return false
    }
    
    open func updateHitTestInfo(hitTestInfo: SCIHitTestInfo, rs: ISCIRenderableSeries, point: CGPoint) {
        rs.verticalSliceHitTest(hitTestInfo, at: point)
    }

    open func isHitPointValid(hitTestInfo: SCIHitTestInfo) -> Bool {
        let isHitTestPointValid = !hitTestInfo.isEmpty && hitTestInfo.isHit

        // if need to perform interpolation we need hit test point to be within data bounds
        return useInterpolation ? isHitTestPointValid && hitTestInfo.isWithinDataBounds : isHitTestPointValid
    }
    
    open func isSeriesValid(series: ISCIRenderableSeries?) -> Bool {
        return series != nil && series?.hasDataSeries ?? false
    }
}
