//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FinanceSeriesPaletteProvider.swift is part of SCICHART®, High Performance Scientific Charts
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

public class FinanceSeriesPaletteProvider: SCIPaletteProviderBase<SCIFastColumnRenderableSeries>, ISCIFillPaletteProvider, ISCIStrokePaletteProvider {
    
    private let inputs: Array<DataSourceId>
    private let seriesColorFunction: (Dictionary<DataSourceId, SCIDoubleValues>, Int) -> UIColor
    
    public init(
        inputs: Array<DataSourceId>,
        seriesColorFunction: @escaping (Dictionary<DataSourceId, SCIDoubleValues>, Int) -> UIColor
    ) {
        self.inputs = inputs
        self.seriesColorFunction = seriesColorFunction
        
        super.init(renderableSeriesType: SCIFastColumnRenderableSeries.self)
    }
    
    private let _fillColors = SCIUnsignedIntegerValues()
    private let _strokeColors = SCIUnsignedIntegerValues()
    
    public override func update() {
        guard
            let renderableSeries = self.renderableSeries,
            let renderPassData = renderableSeries.currentRenderPassData as? SCIXSeriesRenderPassData
        else { return }
        
        let indices = renderPassData.indices
        let count = indices.count
        _fillColors.count = count
        _strokeColors.count = count
        
        let dataMap = getDataMap(services: renderableSeries.services)
        
        let indicesArray = indices.itemsArray
        for index in 0..<count {
            let color = seriesColorFunction(dataMap, indicesArray[index]).colorARGBCode()
            _fillColors.set(color, at: index)
            _strokeColors.set(color, at: index)
        }
    }
    
    private func getDataMap(services: ISCIServiceContainer) -> Dictionary<DataSourceId, SCIDoubleValues> {
        var map = Dictionary<DataSourceId, SCIDoubleValues>()
        
        let dataManager = services.getServiceOfType(IDataManager.self) as! IDataManager
        for input in inputs {
            map[input] = dataManager.getYValues(id: input)
        }
        
        return map
    }
    
    public var fillColors: SCIUnsignedIntegerValues {
        return _fillColors
    }
    
    public var strokeColors: SCIUnsignedIntegerValues {
        return _strokeColors
    }
}
