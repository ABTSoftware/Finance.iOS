//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// DefaultCandleDataProvider.swift is part of SCICHART®, High Performance Scientific Charts
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

open class DefaultCandleDataProvider: DataManagerAttachable, ICandleDataProvider {
    public let xValues: SCIDateValues
    public let xValuesId: DataSourceId
    
    public let openValues: SCIDoubleValues
    public let highValues: SCIDoubleValues
    public let lowValues: SCIDoubleValues
    public let closeValues: SCIDoubleValues
    
    public let openValuesId: DataSourceId
    public let highValuesId: DataSourceId
    public let lowValuesId: DataSourceId
    public let closeValuesId: DataSourceId
    
    public let volumeValues: SCIDoubleValues
    public let volumeValuesId: DataSourceId
    
    private let outputChangedArgs: DataSourceChangedArgs
    
    public var size: Int {
        return xValues.count
    }
    
    public init(ohlcvDataSourceId: OhlcvDataSourceId = OhlcvDataSourceId.DEFAULT_OHLCV_VALUES_IDS) {
        xValues = SCIDateValues()
        xValuesId = ohlcvDataSourceId.xValuesId
        
        openValues = SCIDoubleValues()
        highValues = SCIDoubleValues()
        lowValues = SCIDoubleValues()
        closeValues = SCIDoubleValues()
        
        openValuesId = ohlcvDataSourceId.openValuesId
        highValuesId = ohlcvDataSourceId.highValuesId
        lowValuesId = ohlcvDataSourceId.lowValuesId
        closeValuesId = ohlcvDataSourceId.closeValuesId
        
        volumeValues = SCIDoubleValues()
        volumeValuesId = ohlcvDataSourceId.volumeValuesId
        
        outputChangedArgs = DataSourceChangedArgs(changedDataSourceIds: Set([xValuesId, openValuesId, highValuesId, lowValuesId, closeValuesId, volumeValuesId]))
    }
    
    public override func onDataManagerAttached(_ dataManager: IDataManager) {
        dataManager.registerXValuesSource(id: xValuesId, values: xValues)
        
        dataManager.registerYValuesSource(id: openValuesId, values: openValues)
        dataManager.registerYValuesSource(id: highValuesId, values: highValues)
        dataManager.registerYValuesSource(id: lowValuesId, values: lowValues)
        dataManager.registerYValuesSource(id: closeValuesId, values: closeValues)
        
        dataManager.registerYValuesSource(id: volumeValuesId, values: volumeValues)
    }
    
    public override func onDataManagerDetached(_ dataManager: IDataManager) {
        dataManager.unregisterXValuesSource(id: xValuesId)
        
        dataManager.unregisterYValuesSource(id: openValuesId)
        dataManager.unregisterYValuesSource(id: highValuesId)
        dataManager.unregisterYValuesSource(id: lowValuesId)
        dataManager.unregisterYValuesSource(id: closeValuesId)
        
        dataManager.unregisterYValuesSource(id: volumeValuesId)
    }
    
    public func clear() {
        writeLock {
            xValues.clear()

            openValues.clear()
            highValues.clear()
            lowValues.clear()
            closeValues.clear()

            volumeValues.clear()
            onDataProviderDrasticallyChanged()
        }
    }
    
    public func writeLock(modifyAction: () -> Void) {
        // if dataManager is available update data using lock,
        // otherwise data provider isn't attached to chart so there is no need to use lock
        // and we just update data stored in data provider
        
        if let dataManager = dataManager {
            dataManager.writeLock(modifyAction: modifyAction)
        } else {
            modifyAction()
        }
    }
    
    open func onDataProviderDrasticallyChanged() {
        dataManager?.onDataSourceChanged(args: outputChangedArgs)
    }
}
