//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// EditablePropertyBase.swift is part of SCICHART®, High Performance Scientific Charts
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

open class EditablePropertyBase<T: Equatable>: EditableItem, IEditableProperty {
    private let _name: String
    open override var name: String {
        return _name
    }
    
    private let parentName: String
    
    public var propertyId: PropertyId {
        return PropertyId(entityId: parentName, propertyName: name)
    }
    
    public private(set) var initialValue: T
    private let listener: (PropertyId, T) -> Void
    
    private var _value: T!
    public private(set) var value: T {
        get { _value }
        set {
            if _value != newValue {
                _value = newValue
                listener(propertyId, value)
            }
        }
    }
    
    public init(
        name: String,
        parentName: String,
        viewType: ViewType,
        initialValue: T,
        listener: @escaping (PropertyId, T) -> Void
    ) {
        self._name = name
        self.parentName = parentName
        self.initialValue = initialValue
        self.listener = listener
        
        super.init(viewType: viewType)
        
        self.value = initialValue
        
        self.listener(propertyId, value)
    }
    
    @discardableResult
    public func trySetValue(_ value: T) -> SetPropertyResult {
        let result = isValidValue(value)
        
        switch result {
        case .success:
            self.value = value
        default:
            break
        }

        return result
    }
    
    public func updateInitialValue(_ value: T) {
        initialValue = value
        self.value = value
    }
    
    open override func reset() {
        value = initialValue
    }
    
    public func isValidValue(_ value: T) -> SetPropertyResult {
        return .success
    }
}

public enum SetPropertyResult {
    case fail(String)
    case success
}
