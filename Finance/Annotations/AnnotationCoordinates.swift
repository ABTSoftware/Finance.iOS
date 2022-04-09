//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// AnnotationCoordinates.swift is part of SCICHART®, High Performance Scientific Charts
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

public class AnnotationCoordinates: Equatable {
    public static func == (lhs: AnnotationCoordinates, rhs: AnnotationCoordinates) -> Bool {
        return
            lhs.x1 == rhs.x1 &&
            lhs.y1 == rhs.y1 &&
            lhs.x2 == rhs.x2 &&
            lhs.y2 == rhs.y2
    }
    
    public var x1: Double?
    public var y1: Double?
    public var x2: Double?
    public var y2: Double?
    
    public init(x1: Double?, y1: Double?, x2: Double?, y2: Double?) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }
}
