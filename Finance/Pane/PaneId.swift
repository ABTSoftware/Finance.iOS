//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// PaneId.swift is part of SCICHART®, High Performance Scientific Charts
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

@objc public class PaneId: NSObject, Codable {
    static func == (lhs: PaneId, rhs: PaneId) -> Bool {
        return lhs.id == rhs.id
    }
    
    public let id: String
    
    init(id: String) {
        self.id = id
    }
    
    public static let DEFAULT_PANE = PaneId(id: "DefaultPane")
    
    public static func uniqueId(name: String) -> PaneId {
        return PaneId(id: "\(name)\(Date().timeIntervalSince1970)")
    }
    
    public override var description: String {
        return id
    }
}
