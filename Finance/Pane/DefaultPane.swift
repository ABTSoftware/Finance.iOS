//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// DefaultPane.swift is part of SCICHART®, High Performance Scientific Charts
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

@objc public protocol PaneDelegate: AnyObject {
    func onPaneHeightRatioChange(_ paneHeightRatio: CGFloat)
}

open class DefaultPane: IPane, IFinanceChartEventListener {
    public weak var delegate: PaneDelegate?
    
    public let chart: ISCIChartSurface
    public let xAxis: ISCIAxis
    public let paneId: PaneId
    
    private let studyLegend: StudyLegend
    private let expandButton: ExpandButton
    private let logo: SciChartLogoView
    private let modifiers: DefaultChartModifiers
    
    public init(
        chart: SCIChartSurface,
        xAxis: ISCIAxis,
        studyLegend: StudyLegend,
        expandButton: ExpandButton,
        logo: SciChartLogoView,
        modifiers: DefaultChartModifiers,
        paneId: PaneId
    ) {
        self.chart = chart
        self.xAxis = xAxis
        self.studyLegend = studyLegend
        self.expandButton = expandButton
        self.logo = logo
        self.modifiers = modifiers
        self.paneId = paneId
    }
    
    private var studiesCounter = 0
    private var cachedAxisViewportDimension: CGFloat = 0
    
    open var rootView: UIView {
        chartContainer.view
    }
    
    open var isCursorEnabled: Bool {
        get {
            return modifiers.isCursorEnabled
        }
        
        set {
            modifiers.isCursorEnabled = newValue
            studyLegend.showSeriesTooltips = newValue
        }
    }
    
    open var chartTheme: SCIChartTheme {
        get { chart.theme }
        set { (chart as? SCIChartSurface)?.theme = newValue }
    }
    
    open var isXAxisVisible: Bool {
        get {
            return xAxis.isVisible
        }
        
        set {
            xAxis.isVisible = newValue
            isLogoVisible = xAxis.isVisible
        }
    }
    
    open var isLogoVisible: Bool {
        get {
            !logo.isHidden
        }
        
        set {
            logo.isHidden = !newValue
        }
    }
    
    open var isExpandButtonEnabled: Bool {
        get { expandButton.isEnabled }
        
        set {
            expandButton.updateIsEnabled(newValue)
        }
    }
    
    lazy open var chartContainer: IChartContainer = {
        let container = paneId == PaneId.DEFAULT_PANE ? MainChartContainer() : SecondaryChartContainer(pane: self)
        
        return container
    }()
    
    lazy open var topButtonsContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        return stackView
    }()
    
    open func placeInto(financeChart: ISciFinanceChart) {
        chartContainer.placeChart(chart)
        
        financeChart.addListener(self)
        financeChart.addPane(self)
        
        chart.setRenderedListener { [weak self] surface, _ in
            guard
                let self = self,
                let axisViewportDimension = surface?.xAxes.firstOrDefault()?.axisViewportDimension
            else { return }
            
            if self.cachedAxisViewportDimension != axisViewportDimension {
                self.cachedAxisViewportDimension = axisViewportDimension
                
                self.onResize(axisViewportDimension: axisViewportDimension)
            }
        }
        
        placeStudyLegend()
        
        placeTopButtonsContainer()
        topButtonsContainer.addArrangedSubview(expandButton)

        expandButton.action = { [weak self] in
            guard let self = self else { return }
            
            let isExpanded = financeChart.toggleFullscreenOnPane(self.paneId)
            self.expandButton.updateIcon(isExpanded)
            self.expandButton.selectionHapticFeedback()
        }
        
        logo.place(on: chartContainer.view, relatedTo: chart.modifierSurface.view)
    }
    
    private func placeTopButtonsContainer() {
        chartContainer.view.addSubview(topButtonsContainer)
        
        let relatedTo = chart.modifierSurface.view
        
        topButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topButtonsContainer.trailingAnchor.constraint(equalTo: relatedTo.trailingAnchor),
            topButtonsContainer.topAnchor.constraint(equalTo: relatedTo.topAnchor)
        ])
    }
    
    open func removeFrom(financeChart: ISciFinanceChart) {
        topButtonsContainer.removeAllArrangedSubviews()
        
        for i in 0..<modifiers.modifierGroup.childModifiers.count {
            let modifier = modifiers.modifierGroup.childModifiers[i]
            
            if let gesture = (modifier as? SCIGestureModifierBase)?.gestureRecognizer {
                gesture.view?.removeGestureRecognizer(gesture)
            }
        }
        
        chart.setRenderedListener(nil)
        financeChart.removeListener(self)
        financeChart.removePane(self)
    }
    
    private func placeStudyLegend() {
        let legendSuperView = chart.renderableSeriesArea.view
        legendSuperView.addSubview(studyLegend)
        studyLegend.translatesAutoresizingMaskIntoConstraints = false
        
        studyLegend.topAnchor.constraint(equalTo: legendSuperView.topAnchor, constant: 10).isActive = true
        studyLegend.leadingAnchor.constraint(equalTo: legendSuperView.leadingAnchor, constant: 10).isActive = true
        
        let trailingAnchor = studyLegend.trailingAnchor.constraint(lessThanOrEqualTo: legendSuperView.trailingAnchor, constant: 0)
        trailingAnchor.priority = .defaultHigh
        trailingAnchor.isActive = true
    }
    
    open func addStudy(study: IStudy) {
        studiesCounter += 1
        study.placeInto(pane: self)
        
        let studyTooltip = study.getStudyTooltip()

        studyLegend.addTooltip(studyTooltip: studyTooltip)
    }
    
    open func removeStudy(study: IStudy) {
        study.removeFrom(pane: self)
        studiesCounter -= 1

        studyLegend.removeTooltip(studyId: study.id)
    }
    
    open var hasStudies: Bool {
        return studiesCounter > 0
    }
    
    open func onStudyChanged(studyId: StudyId) {
        studyLegend.onStudyChanged(studyId: studyId)
    }
    
    open func onExpandAnimationStart() {
        logo.alpha = 0
        modifiers.crosshairModifier.clearAll()
    }
    
    open func onExpandAnimationFinish() {
        UIView.animate(withDuration: 0.2) {
            self.logo.alpha = 1
        }
        
        modifiers.crosshairModifier.normilizeLastUpdatedPoint()
    }
    
    public func onResize(axisViewportDimension: CGFloat) {
        self.modifiers.crosshairModifier.normilizeLastUpdatedPoint()
    }
    
    // MARK: - IFinanceChartEventListener
    public var listenerId: UUID = UUID()
    
    public func onFinanceChartEvent(_ event: IFinanceChartEvent) {
        if let event = event as? FinanceChartAnimateRangeEvent,
           let xAxis = self.chart.xAxes.firstOrDefault() {
            xAxis.animateVisibleRange(to: event.range, withDuration: 0.2)
        }
    }
    
    public func savePropertyStateTo(chartState: PropertyState, paneState: PropertyState) {
        if let container = chartContainer as? IResizingView {
            paneState.write(property: container.paneHeightRatioKey, value: Float(container.paneHeightRatio))
        }
        
        modifiers.crosshairModifier.savePropertyStateTo(chartState: chartState, paneState: paneState)
    }
    
    public func restorePropertyStateFrom(chartState: PropertyState, paneState: PropertyState) {
        if let container = chartContainer as? IResizingView,
           let paneHeightRatio = paneState.read(property: container.paneHeightRatioKey) as? Float {
            container.paneHeightRatio = CGFloat(paneHeightRatio)
        }
        
        modifiers.crosshairModifier.restorePropertyStateFrom(chartState: chartState, paneState: paneState)
    }
    
    public func onPaneHeightRatioChange(_ paneHeightRatio: CGFloat) {
        delegate?.onPaneHeightRatioChange(paneHeightRatio)
    }
    
    open class DefaultChartModifiers {
        let modifierGroup: SCIModifierGroup
        let crosshairModifier: CrosshairModifier
        let zoomPanModifier: FinanceZoomPanModifier
        
        public init(
            modifierGroup: SCIModifierGroup,
            crosshairModifier: CrosshairModifier,
            zoomPanModifier: FinanceZoomPanModifier
        ) {  
            self.modifierGroup = modifierGroup
            self.crosshairModifier = crosshairModifier
            self.zoomPanModifier = zoomPanModifier
        }
        
        var isCursorEnabled: Bool {
            get {
                return crosshairModifier.isEnabled
            }
            
            set {
                crosshairModifier.isEnabled = newValue
                zoomPanModifier.isEnabled = !newValue
            }
        }
    }
}
