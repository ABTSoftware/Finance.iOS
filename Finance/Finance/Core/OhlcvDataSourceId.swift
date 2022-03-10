//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// OhlcvDataSourceId.swift is part of SCICHART®, High Performance Scientific Charts
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

public struct OhlcvDataSourceId {
    public let xValuesId: DataSourceId
    public let openValuesId: DataSourceId
    public let highValuesId: DataSourceId
    public let lowValuesId: DataSourceId
    public let closeValuesId: DataSourceId
    public let volumeValuesId: DataSourceId
    
    public static let DEFAULT_OHLCV_VALUES_IDS =
        OhlcvDataSourceId(xValuesId: DataSourceId.DEFAULT_X_VALUES_ID,
                          openValuesId: DataSourceId.DEFAULT_OPEN_VALUES_ID,
                          highValuesId: DataSourceId.DEFAULT_HIGH_VALUES_ID,
                          lowValuesId: DataSourceId.DEFAULT_LOW_VALUES_ID,
                          closeValuesId: DataSourceId.DEFAULT_CLOSE_VALUES_ID,
                          volumeValuesId: DataSourceId.DEFAULT_VOLUME_VALUES_ID
        )
}
