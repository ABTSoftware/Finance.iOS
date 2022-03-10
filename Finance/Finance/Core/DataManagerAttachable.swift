//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// DataManagerAttachable.swift is part of SCICHART®, High Performance Scientific Charts
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

open class DataManagerAttachable: AttachableBase {
    
    open var dataManager: IDataManager?
    
    open override func attach(to services: ISCIServiceContainer) {
        super.attach(to: services)
        
        dataManager = self.services.getServiceOfType(IDataManager.self) as? IDataManager
        if let dataManager = dataManager {
            onDataManagerAttached(dataManager)
        }
    }
    
    func onDataManagerAttached(_ dataManager: IDataManager) {
        fatalError("Must be implemented in subclasses")
    }
    
    open override func detach() {
        if let dataManager = dataManager {
            onDataManagerDetached(dataManager)
        }
        
        dataManager = nil
        
        super.detach()
    }
    
    func onDataManagerDetached(_ dataManager: IDataManager) {
        fatalError("Must be implemented in subclasses")
    }
}
