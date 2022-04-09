//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// StudyId.swift is part of SCICHART®, High Performance Scientific Charts
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

@objc public class StudyId: NSObject, Codable {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
    
    public override var description: String {
        return id
    }
    
    public static func uniqueId(name: String) -> StudyId {
        return StudyId(id: "\(name)\(Date().timeIntervalSince1970)")
    }
    
    public static let DEFAULT_X_VALUES_ID = DataSourceId(id: "xValues")
    public static let DEFAULT_OPEN_VALUES_ID = DataSourceId(id: "open")
    public static let DEFAULT_HIGH_VALUES_ID = DataSourceId(id: "high")
    public static let DEFAULT_LOW_VALUES_ID = DataSourceId(id: "low")
    public static let DEFAULT_CLOSE_VALUES_ID = DataSourceId(id: "close")
    public static let DEFAULT_VOLUME_VALUES_ID = DataSourceId(id: "volume")
    public static let DEFAULT_Y_VALUES_ID = DEFAULT_CLOSE_VALUES_ID
}
