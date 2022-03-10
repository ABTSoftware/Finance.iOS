//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// EnumEditableProperty.swift is part of SCICHART®, High Performance Scientific Charts
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

public protocol IEnumValues {
    associatedtype E: RawRepresentable & CaseIterable
    
    var enumValues: [E] { get }
}

public class EnumEditableProperty<E: RawRepresentable & CaseIterable>: EditablePropertyBase<Int>, IEnumValues where E.RawValue == Int {
    public var enumValue: E {
        return E(rawValue: value)!
    }
    
    public var enumValues: [E] {
        return E.allCases as! [E]
    }
    
    public init(name: String, parentName: String, initialValue: E, listener: @escaping (PropertyId, E) -> Void) {
        let intListener: (PropertyId, Int) -> Void = { id, rawValue in
            if let enumValue = E(rawValue: rawValue) {
                listener(id, enumValue)
            }
        }
        super.init(name: name, parentName: parentName, viewType: .maTypeProperty, initialValue: initialValue.rawValue, listener: intListener)
    }
}
