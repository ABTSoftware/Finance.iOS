//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// BoxAnnotation.swift is part of SCICHART®, High Performance Scientific Charts
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

public class BoxAnnotation: FinanceAnnotationBase {
    
    private var _name: String = FinanceString.boxAnnotation.name
    public override var name: String { _name }
    
    private lazy var _annotation = SCIBoxAnnotation()
    public override var annotation: SCIBoxAnnotation {
        return _annotation
    }
    
    @EditableProperty
    public var strokeStyleProperty: PenStyleEditableProperty!
    
    @EditableProperty
    public var brushStyleProperty: BrushStyleEditableProperty!
    
    public init(
        coordinates: AnnotationCoordinates,
        strokeStyle: SCIPenStyle = SCISolidPenStyle(color: .green, thickness: 1),
        fillStyle: SCIBrushStyle = SCISolidBrushStyle(color: .brown)
    ) {
        super.init(coordinates: coordinates, parentName: _name)
        
        strokeStyleProperty = PenStyleEditableProperty(
            name: FinanceString.strokeStyle.name,
            parentName: name,
            initialValue: strokeStyle) { [weak self] id, value in
            self?.annotation.borderPen = value
            
            // MARK: - TODO:
//            self?.onPropertyChanged...
        }
        
        brushStyleProperty = BrushStyleEditableProperty(
            name: FinanceString.fillStyle.name,
            parentName: name,
            initialValue: fillStyle) { [weak self] id, value  in
            self?.annotation.fillBrush = value
            // MARK: - TODO:
//            self?.onPropertyChanged...
        }
        
        coordinatesProperty.coordinateTypes = [.x1, .y1, .x2, .y2]
    }
    
    public override func reset() {
        super.reset()
        
        strokeStyleProperty.reset()
        brushStyleProperty.reset()
    }
}
