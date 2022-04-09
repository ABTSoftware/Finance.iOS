//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// TextAnnotation.swift is part of SCICHART®, High Performance Scientific Charts
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

public class TextAnnotation: FinanceAnnotationBase {
    
    private var _name: String = FinanceString.textAnnotation.name
    public override var name: String { _name }
    
    private lazy var _annotation: SCITextAnnotation = SCITextAnnotation()
    public override var annotation: SCITextAnnotation {
        return _annotation
    }
    
    @EditableProperty
    public var fontStyleProperty: FontStyleEditableProperty!
    
    @EditableProperty
    public var textProperty: StringEditableProperty!
    
    
    public init(
        coordinates: AnnotationCoordinates,
        fontStyle: SCIFontStyle = SCIFontStyle(fontSize: 12, andTextColor: .white),
        textStyle: String = "Custom Text"
    ) {
        super.init(coordinates: coordinates, parentName: _name)
        
        fontStyleProperty = FontStyleEditableProperty(
            name: FinanceString.fontStyle.name,
            parentName: name,
            initialValue: fontStyle,
            listener: { [weak self] id, value  in
                self?.annotation.fontStyle = value
                // MARK: - TODO:
                // self?.onPropertyChanged...
            }
        )
        
        textProperty = StringEditableProperty(
            name: FinanceString.textStyle.name,
            parentName: name,
            initialValue: textStyle,
            listener: { [weak self] id, value in
                self?.annotation.text = value
                // MARK: - TODO:
                // self?.onPropertyChanged...
            }
        )
        
        coordinatesProperty.coordinateTypes = [.x1, .y1]
        
        _annotation.canEditText = false
    }
    
    public override func reset() {
        super.reset()
        
        fontStyleProperty.reset()
        textProperty.reset()
    }
}
