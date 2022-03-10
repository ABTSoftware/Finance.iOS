//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// DataSourceEditableProperty.swift is part of SCICHART®, High Performance Scientific Charts
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

public class DataSourceEditableProperty: EditablePropertyBase<DataSourceId> {
    public init(name: String, parentName: String, initialValue: DataSourceId, listener: @escaping (PropertyId, DataSourceId) -> Void) {
        super.init(name: name, parentName: parentName, viewType: .dataSourceIdProperty, initialValue: initialValue, listener: listener)
    }
    
    /*
     override fun trySetValue(value: Any?) {
     if (value is DataSourceId) {
     this.value = value
     }
     }
     */
}
