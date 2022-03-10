//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// HorizontalLineAnnotation.swift is part of SCICHART®, High Performance Scientific Charts
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

public class HorizontalLineAnnotation: FinanceAnnotationBase {
    
    private let _name: String = FinanceString.lineAnnotation.name
    public override var name: String { _name }
    
    private lazy var _annotation = SCIHorizontalLineAnnotation()
    public override var annotation: SCIHorizontalLineAnnotation {
        return _annotation
    }
    
    @EditableProperty
    public var strokeStyleProperty: PenStyleEditableProperty!
    
    public init(coordinates: AnnotationCoordinates, strokeStyle: SCIPenStyle = SCISolidPenStyle(color: .green, thickness: 1)) {
        super.init(coordinates: coordinates, parentName: _name)
        
        strokeStyleProperty = PenStyleEditableProperty(
            name: FinanceString.strokeStyle.name,
            parentName: name,
            initialValue: strokeStyle,
            listener: { [weak self] id, value in
                self?.annotation.stroke = value
                // MARK: - TODO:
                // self?.onPropertyChanged...
            }
        )
        
        coordinatesProperty.coordinateTypes = [.y1]
    }

    public override func reset() {
        super.reset()
        
        strokeStyleProperty.reset()
    }
}
