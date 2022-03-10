//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// StudyBase.swift is part of SCICHART®, High Performance Scientific Charts
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

import Foundation
import SciChart

open class StudyBase: AttachableBase, IStudy, IFinanceChartEventListener {
    public let viewType = ViewType.study
    
    open var financeChart: ISciFinanceChart?
    
    public let financeSeries = FinanceSeriesCollection()
    public let financeYAxes = FinanceAxisCollection()
    public let indicators = IndicatorCollection()
    
    open var name: String { title }
    open var title: String { "Default name" }
    
    open var id: StudyId
    open var pane: PaneId
    
    private var studyChangeListeners = [IStudyEventListener]()
    
    public init(id: StudyId, pane: PaneId) {
        self.id = id
        self.pane = pane
        
        super.init()
        
        services.registerService(self, ofType: IStudy.self)
        
        financeSeries.addObserver { [weak self] collection, args in
            self?.onObservableCollectionChanged(collection: collection, args: args)
        }
        
        financeYAxes.addObserver { [weak self] collection, args in
            self?.onObservableCollectionChanged(collection: collection, args: args)
        }
        
        indicators.addObserver { [weak self] collection, args in
            self?.onObservableCollectionChanged(collection: collection, args: args)
        }
    }
    
    private func onObservableCollectionChanged<T: ISCIAttachable>(collection: SCIObservableCollection<T>, args: SCICollectionChangedEventArgs<T>) {
        if !isAttached { return }
        
        args.oldItems.detach()
        args.newItems.attach(to: services)
    }
    
    open override func attach(to services: ISCIServiceContainer) {
        super.attach(to: services)
        
        indicators.attach(to: self.services)
        financeSeries.attach(to: self.services)
        financeYAxes.attach(to: self.services)
        
        financeChart = self.services.getServiceOfType(ISciFinanceChart.self) as? ISciFinanceChart
        financeChart?.addListener(self)
    }
    
    open override func detach() {
        financeSeries.detach()
        financeYAxes.detach()
        // Indicators should be detached p
        indicators.detach()

        financeChart?.removeListener(self)
        financeChart = nil
        
        super.detach()
    }
    
    open func placeInto(pane: IPane) {
        placeInto(pane: pane, items: financeYAxes.toArray())
        placeInto(pane: pane, items: financeSeries.toArray())
    }
    
    private func placeInto(pane: IPane, items: [IPanePlaceable]) {
        for placeable in items {
            placeable.placeInto(pane: pane)
        }
    }
    
    open func removeFrom(pane: IPane) {
        removeFrom(pane: pane, items: financeYAxes.toArray())
        removeFrom(pane: pane, items: financeSeries.toArray())
    }
    
    private func removeFrom(pane: IPane, items: [IPanePlaceable]) {
        for placeable in items {
            placeable.removeFrom(pane: pane)
        }
    }
    
    open func reset() {
        fatalError("Must be implemented in subclasses")
    }
    
    open func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return true
    }
    
    public func savePropertyStateTo(state: EditablePropertyState) {
        savePropertyStateTo(state: state, items: financeYAxes.toArray())
        savePropertyStateTo(state: state, items: financeSeries.toArray())
        savePropertyStateTo(state: state, items: indicators.toArray())
    }
    
    private func savePropertyStateTo(state: EditablePropertyState, items: [IEditablePropertyContainer]) {
        for item in items {
            item.savePropertyStateTo(state: state)
        }
    }
    
    open func restorePropertyStateFrom(state: EditablePropertyState) {
        restorePropertyStateFrom(state: state, items: financeYAxes.toArray())
        restorePropertyStateFrom(state: state, items: financeSeries.toArray())
        restorePropertyStateFrom(state: state, items: indicators.toArray())
    }
    
    private func restorePropertyStateFrom(state: EditablePropertyState, items: [IEditablePropertyContainer]) {
        for item in items {
            item.restorePropertyStateFrom(state: state)
        }
    }
    
    open func invalidateStudy() {
        financeChart?.onStudyChanged(paneId: pane, studyId: id)
    }
    
    open func getStudyTooltip() -> IStudyTooltip {
        fatalError("Must be implemented in subclasses")
    }
    
    open func onPropertyChanged(_ propertyId: PropertyId) {
        dispatchStudyEvent(StudyChangedEvent(study: self))
    }
    
    open func addListener(_ listener: IStudyEventListener) {
        if !(studyChangeListeners.contains(where: { $0.listenerId == listener.listenerId })) {
            studyChangeListeners.append(listener)
        }
    }
    
    open func removeListener(_ listener: IStudyEventListener) {
        if let index = studyChangeListeners.firstIndex(where: { $0.listenerId == listener.listenerId }) {
            studyChangeListeners.remove(at: index)
        }
    }
    
    open func dispatchStudyEvent(_ event: IStudyEvent) {
        for listener in studyChangeListeners {
            listener.onStudyEvent(event)
        }
    }
    
    // MARK: - IFinanceChartEventListener
    
    open var listenerId: UUID = UUID()
    
    open func onFinanceChartEvent(_ event: IFinanceChartEvent) {
        
    }
}
