//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// MainPane.swift is part of SCICHART®, High Performance Scientific Charts
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

open class MainPane: DefaultPane {
    private let yAxisDragModifier: FinanceYAxisDragModifier
    private let xRangeButton: XRangeButton
    
    public init(
        chart: SCIChartSurface,
        xAxis: ISCIAxis,
        studyLegend: StudyLegend,
        expandButton: ExpandButton,
        xRangeButton: XRangeButton,
        logo: SciChartLogoView,
        yAxisDragModifier: FinanceYAxisDragModifier,
        modifiers: DefaultPane.DefaultChartModifiers,
        paneId: PaneId
    ) {
        self.yAxisDragModifier = yAxisDragModifier
        self.xRangeButton = xRangeButton
        
        super.init(
            chart: chart,
            xAxis: xAxis,
            studyLegend: studyLegend,
            expandButton: expandButton,
            logo: logo,
            modifiers: modifiers,
            paneId: paneId
        )
    }
    
    open lazy var bottomButtonsContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical

        return stackView
    }()
    
    private lazy var visibleRangeObserver: SCIRangeChangeObserver = { [weak self] _, _, _, newMax, _ in
        guard
            let self = self,
            let newMax = newMax as? Date
        else { return }
        
        self.setXRangeButtonVisibility(maxRange: newMax)
    }
    
    private var resizeAction: ((CGFloat) -> Void)?
    
    open override func placeInto(financeChart: ISciFinanceChart) {
        super.placeInto(financeChart: financeChart)
        
        financeChart.sharedXRange.addChangeObserver(visibleRangeObserver)
        
        placeBottomButtonsContainer()

        bottomButtonsContainer.addArrangedSubview(xRangeButton)
        bottomButtonsContainer.addArrangedSubview(yAxisDragModifier.yAutoRangeButton)

        xRangeButton.alpha = 0
        xRangeButton.action = { [weak self] in
            guard let self = self else { return }
            
            self.resetXRangeToTodayDate()
            
            self.xRangeButton.selectionHapticFeedback()
        }
        
        resizeAction = { axisViewportDimension in
            financeChart.dispatchFinanceChartEvent(FinanceChartWidthChangedEvent(width: axisViewportDimension))
        }
    }
    
    public override func onResize(axisViewportDimension: CGFloat) {
        super.onResize(axisViewportDimension: axisViewportDimension)
        
        resizeAction?(axisViewportDimension)
    }
    
    private func placeBottomButtonsContainer() {
        chartContainer.view.addSubview(bottomButtonsContainer)
        let relatedTo = chart.modifierSurface.view
        bottomButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomButtonsContainer.trailingAnchor.constraint(equalTo: relatedTo.trailingAnchor),
            bottomButtonsContainer.bottomAnchor.constraint(equalTo: relatedTo.bottomAnchor)
        ])
    }
    
    private var xRangeButtonIsVisible = false {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.xRangeButton.alpha = self.xRangeButtonIsVisible ? 1 : 0
            }
        }
    }
    
    private func setXRangeButtonVisibility(maxRange: Date) {
        if maxRange >= Date() {
            if xRangeButtonIsVisible {
                xRangeButtonIsVisible = false
            }
        } else {
            if !xRangeButtonIsVisible {
                xRangeButtonIsVisible = true
            }
        }
    }
    
    private func resetXRangeToTodayDate() {
        guard let xAxis = self.chart.xAxes.firstOrDefault() as? SCIDateAxis
        else {
            return
        }
        
        let currentRangeDiff = xAxis.visibleRange.diff.toDouble()
        let xAxisOffset = currentRangeDiff / 5
        let today = Date().timeIntervalSince1970 + xAxisOffset
        let min = today - currentRangeDiff
        let newRange = SCIDateRange(min: Date(timeIntervalSince1970: min), max: Date(timeIntervalSince1970: today))
        
        xAxis.animateVisibleRange(to: newRange, withDuration: 0.2)
    }
    
    open override func removeFrom(financeChart: ISciFinanceChart) {
        super.removeFrom(financeChart: financeChart)
        
        bottomButtonsContainer.removeAllArrangedSubviews()
        
        financeChart.sharedXRange.removeChangeObserver(visibleRangeObserver)
    }
    
    open override func onExpandAnimationStart() {
        super.onExpandAnimationStart()

        yAxisDragModifier.yAutoRangeButton.alpha = 0
    }
    
    open override func onExpandAnimationFinish() {
        super.onExpandAnimationFinish()
        
        UIView.animate(withDuration: 0.2) {
            self.yAxisDragModifier.yAutoRangeButton.alpha = 1
        }
    }
    
    open func excludeAutoRangeAxisId(_ axisId: AxisId) {
        yAxisDragModifier.excludeAxisIds.append(axisId)
    }
    
    open func removeExcludedAutoRangeAxisId(_ axisId: AxisId) {
        if let index = yAxisDragModifier.excludeAxisIds.firstIndex(of: axisId) {
            yAxisDragModifier.excludeAxisIds.remove(at: index)
        }
    }
    
    open override func onFinanceChartEvent(_ event: IFinanceChartEvent) {
        super.onFinanceChartEvent(event)
        
        if let _ = event as? FinanceChartReloadChartEvent {
            yAxisDragModifier.yAutoRange = .always
        }
    }
}
