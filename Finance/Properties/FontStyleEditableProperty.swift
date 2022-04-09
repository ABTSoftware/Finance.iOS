//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FontStyleEditableProperty.swift is part of SCICHART®, High Performance Scientific Charts
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

public class FontStyleEditableProperty: EditablePropertyBase<SCIFontStyle> {
    public init(name: String, parentName: String, initialValue: SCIFontStyle, listener: @escaping (PropertyId, SCIFontStyle) -> Void) {
        super.init(name: name, parentName: parentName, viewType: .font, initialValue: initialValue, listener: listener)
    }
    
    public override func isValidValue(_ value: SCIFontStyle) -> SetPropertyResult {
        let min: CGFloat = 5
        if value.fontDescriptor.pointSize > min {
            return .success
        } else {
            return .fail("Expected value greater then \(min)")
        }
    }
}
