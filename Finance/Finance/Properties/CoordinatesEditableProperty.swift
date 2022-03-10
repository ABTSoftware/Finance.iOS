//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// CoordinatesEditableProperty.swift is part of SCICHART®, High Performance Scientific Charts
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

public class CoordinatesEditableProperty: EditablePropertyBase<AnnotationCoordinates> {
    public var coordinateTypes: [CoordinatesType] = []
    
    public init(name: String,  parentName: String, initialValue: AnnotationCoordinates, listener: @escaping (PropertyId, AnnotationCoordinates) -> Void) {
        super.init(name: name, parentName: parentName, viewType: .annotationCoordinates, initialValue: initialValue, listener: listener)
    }
}

public enum CoordinatesType: String {
    case x1 = "X1"
    case y1 = "Y1"
    case x2 = "X2"
    case y2 = "Y2"
}
