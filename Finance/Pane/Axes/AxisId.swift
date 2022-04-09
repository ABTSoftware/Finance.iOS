//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// AxisId.swift is part of SCICHART®, High Performance Scientific Charts
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

@objc open class AxisId: NSObject {
    public let pane: PaneId
    public let study: StudyId
    public let axisName: String
    
    public init(pane: PaneId, study: StudyId, axisName: String) {
        self.pane = pane
        self.study = study
        self.axisName = axisName
    }
    
    private static let separator: Character = "⎯"
    
    public override var description: String {
        return "\(pane.id)\(AxisId.separator)\(study)\(AxisId.separator)\(axisName)"
    }
    
    public static func fromString(axisId: String) -> AxisId {
        let split = axisId.split(separator: separator)
        if split.count == 3 {
            return AxisId(pane: PaneId(id: String(split[0])), study: StudyId(id: String(split[1])), axisName: String(split[2]))
        } else {
            fatalError("\(axisId) can't be converted to AxisId instance")
        }
    }
}
