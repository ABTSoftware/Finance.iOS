//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FinanceSeriesBase.swift is part of SCICHART®, High Performance Scientific Charts
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

public class FinanceSeriesBase<TRenderableSeries: ISCIRenderableSeries, TDataSeries : ISCIDataSeries>: DependableBase, IFinanceSeries {
    
    public let viewType = ViewType.financeSeries
    public let name: String
    public let renderableSeries: TRenderableSeries
    public let dataSeries: TDataSeries
    
    @EditableProperty
    public var opacity: OpacityEditableProperty!
    
    public var paletteProvider: ISCIPaletteProvider? {
        get { return renderableSeries.paletteProvider }
        set { renderableSeries.paletteProvider = newValue }
    }
    
    public var yAxisId: AxisId {
        didSet {
            renderableSeries.yAxisId = yAxisId.description
        }
    }
    
    public init(name: String, renderableSeries: TRenderableSeries, dataSeries: TDataSeries, yAxisId: AxisId) {
        self.name = name
        self.renderableSeries = renderableSeries
        self.dataSeries = dataSeries
        self.yAxisId = yAxisId
        
        self.renderableSeries.dataSeries = dataSeries
        self.renderableSeries.yAxisId = yAxisId.description
        
        super.init()
        
        self.opacity = OpacityEditableProperty(
            name: FinanceString.financeSeriesOpacity.name,
            parentName: name,
            initialValue: renderableSeries.opacity
        ) { [weak self] id, value in
            self?.renderableSeries.opacity = value
            self?.onPropertyChanged(propertyId: id)
        }
    }
    
    public override func attach(to services: ISCIServiceContainer) {
        super.attach(to: services)
        
        // add data manager so it can be used by FinancePaletteProvider
        if let dataManager = self.dataManager {
            renderableSeries.services.registerService(dataManager, ofType: IDataManager.self)
        }
    }
    
    public override func detach() {
        renderableSeries.services.deregisterService(ofType: IDataManager.self)
        
        super.detach()
    }
    
    public func placeInto(pane: IPane) {
        pane.chart.renderableSeries.add(renderableSeries)
    }

    public func removeFrom(pane: IPane) {
        pane.chart.renderableSeries.remove(renderableSeries)
    }
    
    public func savePropertyStateTo(state: EditablePropertyState) {
        state.savePropertyValues(editable: self)
    }
    
    public func restorePropertyStateFrom(state: EditablePropertyState) {
        state.tryRestorePropertyValues(editable: self)
    }
    
    public func getSeriesInfo() -> SCISeriesInfo {
        return renderableSeries.seriesInfoProvider.seriesInfo
    }
    
    public func getTooltip() -> ISCISeriesTooltip {
        return renderableSeries.seriesInfoProvider.seriesTooltip
    }
    
    public func getTooltip(modifierType: AnyClass) -> ISCISeriesTooltip {
        return renderableSeries.seriesInfoProvider.getSeriesTooltip(modifierType)
    }
    
    public func reset() {
        self.opacity.reset()
    }
    
    open func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return true
    }
}
