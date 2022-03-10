//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// LineArrowAnnotation.swift is part of SCICHART®, High Performance Scientific Charts
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
import SciChart

public class LineArrowAnnotation: FinanceAnnotationBase {
    
    private var _name: String = FinanceString.arrowAnnotation.name
    public override var name: String { _name }
    
    private lazy var _annotation = SCILineArrowAnnotation()
    public override var annotation: SCILineArrowAnnotation {
        _annotation
    }
    
    @EditableProperty
    public var strokeStyleProperty: PenStyleEditableProperty!
    
    @EditableProperty
    public var arrowHeadStyleProperty: ArrowHeadEditableProperty!
    
    public init(
        coordinates: AnnotationCoordinates,
        strokeStyle: SCIPenStyle = SCISolidPenStyle(color: .green, thickness: 1),
        arrowHeadStyle: ArrowHead = ArrowHead(headLength: 4, headWidth: 8)
    ) {
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
        
        arrowHeadStyleProperty = ArrowHeadEditableProperty(
            name: FinanceString.arrowHeadStyle.name,
            parentName: name,
            initialValue: arrowHeadStyle,
            listener: { [weak self] id, arrowHeadStyle  in
                self?.annotation.headLength = arrowHeadStyle.headLength
                self?.annotation.headWidth = arrowHeadStyle.headWidth
                // MARK: - TODO:
                // self?.onPropertyChanged...
            }
        )
        
        coordinatesProperty.coordinateTypes = [.x1, .y1, .x2, .y2]
    }
    
    public override func reset() {
        super.reset()
        
        strokeStyleProperty.reset()
        arrowHeadStyleProperty.reset()
    }
}
