//******************************************************************************
// SCICHARTÂ® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// ViewType.swift is part of SCICHARTÂ®, High Performance Scientific Charts
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

@objc public enum ViewType: Int {
    // Composite Properties
    case yAxis
    case indicator
    case financeSeries
    
    // Editable Properties
    case integerProperty
    case floatProperty
    case doubleProperty
    case penStyleProperty
    case brushStyleProperty
    case font

    case study
    case annotation
    case annotationCoordinates
    case arrowHead

    case dataSourceIdProperty
    case stringProperty
    case text
    case maTypeProperty
}
