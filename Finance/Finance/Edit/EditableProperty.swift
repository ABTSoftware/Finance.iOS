//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// EditableProperty.swift is part of SCICHART®, High Performance Scientific Charts
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

public protocol EditablePropertyProtocol {
    var value: Any! { get }
}

@propertyWrapper
public struct EditableProperty<T: IEditable>: EditablePropertyProtocol {
    public var value: Any! { editable }
    
    private var editable: T!
    public var wrappedValue: T! {
        get { return editable }
        set { editable = newValue }
    }
    
    public init() {
        editable = nil
    }
}
