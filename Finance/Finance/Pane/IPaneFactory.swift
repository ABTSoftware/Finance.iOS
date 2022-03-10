//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// IPaneFactory.swift is part of SCICHART®, High Performance Scientific Charts
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

protocol IPaneFactory {
    func createPane(financeChart: ISciFinanceChart, paneId: PaneId) -> IPane
}

class DefaultPaneFactory: IPaneFactory {
    private let chartState: FinanceChartState
    
    init(chartState: FinanceChartState = FinanceChartState()) {
        self.chartState = chartState
    }
    
    func createPane(financeChart: ISciFinanceChart, paneId: PaneId) -> IPane {
        let globalState = chartState.chartState
        let paneState = chartState.paneStates[paneId.id] ?? PropertyState()
        
        let xAxis = FinanceDateXAxis()
        xAxis.maxAutoTicks = 6
        xAxis.axisInfoProvider = FinanceNumericYAxis.FinanceNumericAxisInfoProvider()
        xAxis.dataRangeChangeListener = { (axis: ISCIAxisCore) in
            guard
                let axis = axis as? SCIDateAxis,
                let min = axis.dataRange.min as? Date,
                let max = axis.dataRange.max as? Date
            else {
                return
            }
            let clone = SCIDateRange(min: min, max: max)
            let diff = axis.visibleRange.diff.toDouble() * 0.95

            clone.setDoubleMinTo(clone.minAsDouble - diff, maxTo: clone.maxAsDouble + diff)

            axis.visibleRangeLimit = clone
        }

        let studyLegend = StudyLegend()
        
        let zoomPanModifier = FinanceZoomPanModifier()
        zoomPanModifier.clipModeX = .clipAtExtents
        zoomPanModifier.clipModeTargetX = .visibleRangeLimit
        
        let crosshairModifier = CrosshairModifier(studyLegend: studyLegend)
        crosshairModifier.gestureView = financeChart as? UIView
        crosshairModifier.receiveHandledEvents = true
        crosshairModifier.eventsGroupTag = "CrosshairModifier"
        
        let xAxisDragModifier = SCIXAxisDragModifier()
        xAxisDragModifier.dragMode = .pan
        xAxisDragModifier.receiveHandledEvents = true
        
        let modifierGroup = SCIModifierGroup(childModifiers: [
            zoomPanModifier,
            crosshairModifier,
            xAxisDragModifier
        ])
        modifierGroup.eventsGroupTag = "FinanceChart"
        modifierGroup.receiveHandledEvents = true
        
        let chart = FinanceChartSurface(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        chart.xAxes.add(xAxis)
        chart.chartModifiers.add(items: modifierGroup)
        
        let paneModifiers = DefaultPane.DefaultChartModifiers(
            modifierGroup: modifierGroup,
            crosshairModifier: crosshairModifier,
            zoomPanModifier: zoomPanModifier
        )
        
        let expandButton = ExpandButton()
        let logoView = SciChartLogoView()
        
        let pane: IPane
        
        if paneId == PaneId.DEFAULT_PANE {
            let autoRangeButton = YAutoRangeButton()
            let yAxisDragModifier = FinanceYAxisDragModifier(autoRangeButton: autoRangeButton)
            yAxisDragModifier.dragMode = .scale
            yAxisDragModifier.receiveHandledEvents = true
            
            paneModifiers.modifierGroup.childModifiers.add(yAxisDragModifier)
            
            let pinchZoomModifier = FinancePinchZoomModifier()
            pinchZoomModifier.receiveHandledEvents = true
            pinchZoomModifier.eventsGroupTag = "FinancePinchZoomModifier"
            pinchZoomModifier.gestureView = financeChart as? UIView
            
            paneModifiers.modifierGroup.childModifiers.add(pinchZoomModifier)
            
            pane = MainPane(
                chart: chart,
                xAxis: xAxis,
                studyLegend: studyLegend,
                expandButton: expandButton,
                xRangeButton: XRangeButton(),
                logo: logoView,
                yAxisDragModifier: yAxisDragModifier,
                modifiers: paneModifiers,
                paneId: paneId
            )
        } else {
            pane = DefaultPane(
                chart: chart,
                xAxis: xAxis,
                studyLegend: studyLegend,
                expandButton: expandButton,
                logo: logoView,
                modifiers: paneModifiers,
                paneId: paneId
            )
        }
        
        pane.restorePropertyStateFrom(chartState: globalState, paneState: paneState)
        
        return pane
    }
}

class FinanceChartSurface: SCIChartSurface {
    // in SCIChartSurface.didMoveToWindow modifiers are attached when view moves to window and detached when surface moves out. It doesn't allow to proper disable the cursor modifier (axes tooltips don't clear). So, for now we have call super.didMoveToWindow() only if view moves to window and do nothing when it moves out to prevent modifiers detaching.
    // Need more investigation whether we need to detach them at all.
    override func didMoveToWindow() {
        if window != nil {
            super.didMoveToWindow()
        }
    }
}
