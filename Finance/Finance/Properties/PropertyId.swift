//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// PropertyId.swift is part of SCICHART®, High Performance Scientific Charts
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

@objc public class PropertyId: NSObject {
    let entityId: String
    let propertyName: String
    
    init(entityId: String, propertyName: String) {
        self.entityId = entityId
        self.propertyName = propertyName
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? PropertyId {
            return self.entityId == object.entityId
        }
        
        return super.isEqual(object)
    }
}
