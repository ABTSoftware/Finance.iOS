//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// DependableBase.swift is part of SCICHART®, High Performance Scientific Charts
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

public class DependableBase: DataManagerAttachable, IDataManagerObserver {
    public var id: String = UUID().uuidString
    
    private var dependsOn = Dictionary<FinanceString, DataSourceId>()
    
    @Atomic private var propertyChanged: Bool = false
    private var parentStudy: IStudy?
    
    public override func attach(to services: ISCIServiceContainer) {
        super.attach(to: services)
                
        parentStudy = services.getServiceOfType(IStudy.self) as? IStudy
    }
    
    public override func detach() {
        parentStudy = nil
        
        super.detach()
    }
    
    func dependsOn(propertyId: FinanceString, value: DataSourceId) {
        dependsOn[propertyId] = value
    }
    
    override func onDataManagerAttached(_ dataManager: IDataManager) {
        dataManager.addDataManagerObserver(observer: self)
        
        onDataDrasticallyChanged(dataManager: dataManager)
    }
    
    override func onDataManagerDetached(_ dataManager: IDataManager) {
        onDataDrasticallyChanged(dataManager: dataManager)
        dataManager.removeDataManagerObserver(observer: self)
    }
    
    public func onDataSourceChanged(dataManager: IDataManager, args: DataSourceChangedArgs) {
        let needToUpdate = args.changedDataSourceIds.contains(where: dependsOn.values.contains) || propertyChanged
        propertyChanged = false
        
        if needToUpdate {
            onDataDrasticallyChanged(dataManager: dataManager)
        }
    }
    
    func onDataDrasticallyChanged(dataManager: IDataManager) {
        fatalError("Must be implemented in subclasses")
    }
    
    func onDataSourceChanged(args: DataSourceChangedArgs) {
        // set is dirty flag to update this instance even if inputs aren't changed
        // then notify all dependencies that output of this instance changed
        propertyChanged = true
        onDataProviderChanged(args: args)
    }
    
    func onPropertyChanged(propertyId: PropertyId) {
        parentStudy?.onPropertyChanged(propertyId)
    }

    func onDataProviderChanged(args: DataSourceChangedArgs) {
        dataManager?.onDataSourceChanged(args: args)
    }
}
