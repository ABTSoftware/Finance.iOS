//******************************************************************************
// SCICHARTÂ® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// IStudyTooltip.swift is part of SCICHARTÂ®, High Performance Scientific Charts
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

@objc public protocol IStudyTooltip: ISCITooltip {
    var studyId: StudyId { get }

    func update()
    func update(point: CGPoint)

    var showSeriesTooltips: Bool { get set }
}
