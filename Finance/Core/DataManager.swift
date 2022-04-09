//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// DataManager.swift is part of SCICHART®, High Performance Scientific Charts
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

class DataManager: IDataManager {
    
    private var observers = Array<IDataManagerObserver>()

    private var xValuesMap = Dictionary<DataSourceId, SCIDateValues>()
    private var yValuesMap = Dictionary<DataSourceId, SCIDoubleValues>()
    
    var lock: ISCIReadWriteLock = SCIReadWriteLock()
    
    func writeLock(modifyAction: () -> Void) {
        lock.writeLock()
        defer {
            self.lock.writeUnlock()
        }
        
        modifyAction()
    }
    
    func readLock(modifyAction: () -> Void) {
        lock.readLock()
        defer {
            self.lock.readUnlock()
        }
        
        modifyAction()
    }

    /**
     * Adds the `IDataManagerObserver` instance into the list to notify if this instance changes
     * @param observer The observer to add
     */
    func addDataManagerObserver(observer: IDataManagerObserver) {
        if !observers.contains(where: { $0.id == observer.id }) {
            observers.append(observer)
        }
    }

    /**
     * Removes the [IDataManagerObserver] instance from the list to notify if this instance changes
     * @param observer The observer to remove
     */
    func removeDataManagerObserver(observer: IDataManagerObserver) {
        if let index = observers.firstIndex(where: { $0.id == observer.id }) {
            observers.remove(at: index)
        }
    }
    
    func getYValues(id: DataSourceId) -> SCIDoubleValues? {
        return yValuesMap[id]
    }
    
    func getXValues(id: DataSourceId) -> SCIDateValues? {
        return xValuesMap[id]
    }
    
    func registerYValuesSource(id: DataSourceId, values: SCIDoubleValues) {
        yValuesMap[id] = values
    }
    
    func registerXValuesSource(id: DataSourceId, values: SCIDateValues) {
        xValuesMap[id] = values
    }
    
    func unregisterYValuesSource(id: DataSourceId) {
        yValuesMap[id] = nil
    }
    
    func unregisterXValuesSource(id: DataSourceId) {
        xValuesMap[id] = nil
    }
    
    func onDataSourceChanged(args: DataSourceChangedArgs) {
        for observer in observers {
            observer.onDataSourceChanged(dataManager: self, args: args)
        }
    }
}
