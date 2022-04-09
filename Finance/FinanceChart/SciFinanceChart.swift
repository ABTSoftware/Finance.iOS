//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// SciFinanceChart.swift is part of SCICHART®, High Performance Scientific Charts
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

@objc public protocol ISciFinanceChart: ISCIServiceProvider, ISCIHitTestable, PaneDelegate {
    var studies: SCIObservableCollection<IStudy> { get }
    var candleDataProvider: ICandleDataProvider? { get set }
    
    var sharedXRange: SCIDateRange { get }

    func onStudyChanged(paneId: PaneId, studyId: StudyId)
    
    /**
     * Register specified `IFinanceChartEventListener` instance as chart listener
     * @param listener The listener instance to add
     */
    func addListener(_ listener: IFinanceChartEventListener)

    /**
     * Removes specified `IFinanceChartEventListener` instance from list of chart listeners
     * @param listener The listener instance to remove
     */
    func removeListener(_ listener: IFinanceChartEventListener)

    /**
     * Send specified `event` to all subscribed `IFinanceChartEventListener` instances
     */
    func dispatchFinanceChartEvent(_ event: IFinanceChartEvent)
    
    func addPane(_ pane: IPane)
    func removePane(_ pane: IPane)
    
    func toggleFullscreenOnPane(_ paneId: PaneId) -> Bool
    
    func saveChartStateTo(state: FinanceChartState)
    func restoreChartStateFrom(state: FinanceChartState)
}

open class SciFinanceChart: UIStackView, ISciFinanceChart {
    private let dataManager = DataManager()
    
    private var chartChangeListeners = [IFinanceChartEventListener]()
    
    private(set) open var services: ISCIServiceContainer = SCIServiceContainer()
    
    private let verticalGroup = SCIChartVerticalGroup()
    
    public let sharedXRange = getDefaultXRange()
    
    var paneFactory: IPaneFactory = DefaultPaneFactory()
    
    private var fullscreenPaneId: PaneId?
    
    public let studies: SCIObservableCollection<IStudy> = SCIObservableCollection()
    
    private var _candleDataProvider: ICandleDataProvider?
    open var candleDataProvider: ICandleDataProvider? {
        get { _candleDataProvider }
        set {
            _candleDataProvider?.detach()
            _candleDataProvider = newValue
            _candleDataProvider?.attach(to: services)
        }
    }
    
    private var paneMap = [PaneMapModel]()
    
    open var chartTheme: SCIChartTheme = .v4Dark {
        didSet {
            for model in paneMap {
                model.pane.chartTheme = chartTheme
            }
        }
    }
    
    open var isCursorEnabled: Bool = false {
        didSet {
            for model in paneMap {
                model.pane.isCursorEnabled = isCursorEnabled
            }
        }
    }
    
    open var minimalZoomConstrain: Double? {
        didSet {
            if let minimalZoomConstrain = minimalZoomConstrain {
                for model in paneMap {
                    model.pane.xAxis.minimalZoomConstrain = NSNumber(value: minimalZoomConstrain)
                }
            }
        }
    }
    
    public var onHasSpaceForNewPaneChange: ((Bool) -> Void)?
    
    public init() {
        super.init(frame: .zero)
        
        services.registerService(self, ofType: ISciFinanceChart.self)
        services.registerService(dataManager, ofType: IDataManager.self)
        
        self.axis = .vertical
        self.spacing = 0
        
        studies.addObserver { [weak self] collection, args in
            guard let self = self else { return }
            
            for study in args.oldItems {
                self.detachStudy(study)
            }
            
            for study in args.newItems {
                self.attachStudy(study)
            }
        }
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        if let firstPane = arrangedSubviews.first {
            let hasSpaceForNewPane = (firstPane.frame.height - self.frame.height / Finance.Constants.defaultSecondaryPaneHeightRatio) > self.frame.height / 3
            
            onHasSpaceForNewPaneChange?(hasSpaceForNewPane)
        }
    }
    
    open func attachStudy(_ study: IStudy) {
        study.attach(to: services)
        attachToLayout(study: study)
    }
    
    open func detachStudy(_ study: IStudy) {
        detachFromLayout(study: study)
        study.detach()
    }
    
    private func attachToLayout(study: IStudy) {
        let pane = getPaneById(paneId: study.pane)
        
        pane.addStudy(study: study)
    }
    
    private func detachFromLayout(study: IStudy) {
        if let model = paneMap.first(where: { $0.paneId == study.pane }) {
            model.pane.removeStudy(study: study)
            
            if !model.pane.hasStudies {
                detachPane(pane: model.pane)
                
                if let index = paneMap.firstIndex(where: { $0.paneId == study.pane }) {
                    paneMap.remove(at: index)
                }
            }
        }
    }
    
    open func getPaneById(paneId: PaneId) -> IPane {
        if let model = paneMap.first(where: { $0.paneId == paneId }) {
            return model.pane
        } else {
            let newPane = paneFactory.createPane(financeChart: self, paneId: paneId)
            
            paneMap.append(PaneMapModel(paneId: paneId, pane: newPane))
            
            attachPane(pane: newPane)
            
            return newPane
        }
    }
    
    private func attachPane(pane: IPane) {
        pane.xAxis.visibleRange = sharedXRange
        pane.isCursorEnabled = isCursorEnabled
        
        verticalGroup.addSurface(toGroup: pane.chart)
        pane.chartTheme = chartTheme

        pane.placeInto(financeChart: self)

        updateXAxisVisibility()
        updateExpandButtonIsEnabled()
        
        if let minimalZoomConstrain = minimalZoomConstrain {
            pane.xAxis.minimalZoomConstrain = NSNumber(value: minimalZoomConstrain)
        }
        
        pane.delegate = self
    }

    private func detachPane(pane: IPane) {
        pane.removeFrom(financeChart: self)

        verticalGroup.removeSurface(fromGroup: pane.chart)
        pane.xAxis.visibleRange = SciFinanceChart.getDefaultXRange()

        updateXAxisVisibility()
        updateExpandButtonIsEnabled()
        
        pane.delegate = nil
    }
    
    private static func getDefaultXRange() -> SCIDateRange {
        return SCIDateRange()
    }
    
    private func updateXAxisVisibility() {
        // make xAxis in all panes except last one invisible
        let lastIndex = paneMap.count - 1
        
        for i in 0..<paneMap.count {
            let pane = paneMap[i].pane
            pane.isXAxisVisible = i == lastIndex
        }
    }
    
    private func updateExpandButtonIsEnabled() {
        let isEnabled = paneMap.count > 1
        paneMap.forEach { model in
            model.pane.isExpandButtonEnabled = isEnabled
        }
    }
    
    public func toggleFullscreenOnPane(_ paneId: PaneId) -> Bool {
        
        guard let toggledPane = paneMap.first(where: { $0.paneId == paneId })?.pane else { return false }
        
        if fullscreenPaneId == nil {
            fullscreenPaneId = paneId
            
            toggledPane.isXAxisVisible = true
        } else {
            fullscreenPaneId = nil
            
            updateXAxisVisibility()
        }
        
        let isExpanded = fullscreenPaneId != nil
        
        for entry in self.paneMap {
            let pane = entry.pane
            
            // need to call onExpandAnimationStart to hide pane subviews, such as logo and yAutoRange buttons to prevent jumping
            pane.onExpandAnimationStart()
        }
        
        // need to change pane alpha and isHidden during a single animation to prevent stackView subviews jumping
        UIView.animate(withDuration: 0.2, animations: {
            for entry in self.paneMap {
                let pane = entry.pane
                
                if toggledPane.paneId != pane.paneId {
                    pane.rootView.alpha = isExpanded ? 0 : 1
                    pane.rootView.isHidden = isExpanded
                }
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            // need to call onExpandAnimationFinish in animation completion to show pane subviews, such as logo and yAutoRange buttons to prevent jumping
            for entry in self.paneMap {
                let pane = entry.pane
                
                pane.onExpandAnimationFinish()
            }
        })
        
        return isExpanded
    }
    
    open func onStudyChanged(paneId: PaneId, studyId: StudyId) {
        if let model = paneMap.first(where: { $0.paneId == paneId }) {
            model.pane.onStudyChanged(studyId: studyId)
        }
    }
    
    public func addListener(_ listener: IFinanceChartEventListener) {
        if !(chartChangeListeners.contains(where: { $0.listenerId == listener.listenerId })) {
            chartChangeListeners.append(listener)
        }
    }
    
    public func removeListener(_ listener: IFinanceChartEventListener) {
        if let index = chartChangeListeners.firstIndex(where: { $0.listenerId == listener.listenerId }) {
            chartChangeListeners.remove(at: index)
        }
    }
    
    public func dispatchFinanceChartEvent(_ event: IFinanceChartEvent) {
        for listener in chartChangeListeners {
            listener.onFinanceChartEvent(event)
        }
    }
    
    open override var view: UIView {
        return self
    }
    
    public func addPane(_ pane: IPane) {
        addArrangedSubview(pane.rootView)
    }
    
    public func removePane(_ pane: IPane) {
        pane.rootView.removeFromSuperview()
    }
    
    public func saveChartStateTo(state: FinanceChartState) {
        for entry in paneMap {
            let paneState = PropertyState()
            entry.pane.savePropertyStateTo(chartState: state.chartState, paneState: paneState)
            
            state.paneStates[entry.paneId.id] = paneState
        }
    }
    
    public func restoreChartStateFrom(state: FinanceChartState) {
        paneFactory = DefaultPaneFactory(chartState: state)
        
        for entry in paneMap {
            if let paneState = state.paneStates[entry.paneId.id] {
                entry.pane.restorePropertyStateFrom(chartState: state.chartState, paneState: paneState)
            }
        }
    }
    
    private struct PaneMapModel {
        let paneId: PaneId
        let pane: IPane
    }
    
    public func toState() -> FinanceChartState {
        let state = FinanceChartState()
        saveChartStateTo(state: state)
        
        return state
    }
    
    public func onPaneHeightRatioChange(_ paneHeightRatio: CGFloat) {
        dispatchFinanceChartEvent(FinanceChartStateChangedEvent(chartState: toState()))
    }
}
