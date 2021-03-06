//******************************************************************************
// SCICHARTÂ® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// IDataManager.swift is part of SCICHARTÂ®, High Performance Scientific Charts
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

@objc public protocol IDataManager {
    var lock: ISCIReadWriteLock { get }
    
    func writeLock(modifyAction: () -> Void)
    func readLock(modifyAction: () -> Void)
    
    func getYValues(id: DataSourceId) -> SCIDoubleValues?
    func getXValues(id: DataSourceId) -> SCIDateValues?

    func registerYValuesSource(id: DataSourceId, values: SCIDoubleValues)
    func registerXValuesSource(id: DataSourceId, values: SCIDateValues)

    func unregisterYValuesSource(id: DataSourceId)
    func unregisterXValuesSource(id: DataSourceId)

    func addDataManagerObserver(observer: IDataManagerObserver)
    func removeDataManagerObserver(observer: IDataManagerObserver)

    func onDataSourceChanged(args: DataSourceChangedArgs)
}

@objc public protocol IDataManagerObserver {
    var id: String { get set }
    func onDataSourceChanged(dataManager: IDataManager, args: DataSourceChangedArgs)
}

