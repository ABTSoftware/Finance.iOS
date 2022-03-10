//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FinanceAnnotationBase.swift is part of SCICHART®, High Performance Scientific Charts
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

public class FinanceAnnotationBase: IFinanceAnnotation, IEditableProperty {
    private let uuid = UUID()
    
    private let parentName: String
    
    public var propertyId: PropertyId {
        return PropertyId(entityId: parentName, propertyName: name)
    }
    
    public let viewType = ViewType.annotation
    
    @EditableProperty
    public var coordinatesProperty: CoordinatesEditableProperty!
    
    public init(coordinates: AnnotationCoordinates, parentName: String) {
        self.parentName = parentName
        
        coordinatesProperty = CoordinatesEditableProperty(
            name: FinanceString.coordinates.name,
            parentName: name,
            initialValue: coordinates,
            listener: { [weak self] id, value in
                guard let self = self else { return }
            
            if let x1 = coordinates.x1 {
                self.annotation.set(x1: x1)
            }
            if let y1 = coordinates.y1 {
                self.annotation.set(y1: y1)
            }
            if let x2 = coordinates.x2 {
                self.annotation.set(x2: x2)
            }
            if let y2 = coordinates.y2 {
                self.annotation.set(y2: y2)
            }
        })
        
        annotation.annotationDragListener = AnnotationDragListener(action: { [weak self] annotation in
            self?.coordinatesProperty.trySetValue(
                AnnotationCoordinates(
                    x1: annotation.getX1(),
                    y1: annotation.getY1(),
                    x2: annotation.getX2(),
                    y2: annotation.getY2()
                )
            )
        })
    }
    
    public static func == (lhs: FinanceAnnotationBase, rhs: FinanceAnnotationBase) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public var annotation: SCIAnnotationBase {
        fatalError("Must be implemented in subclasses")
    }
    
    public var isSelected: Bool {
        get { annotation.isSelected }
        set { annotation.isSelected = newValue }
    }
    
    public var isEditable: Bool {
        get { annotation.isEditable }
        set { annotation.isEditable = newValue }
    }
        
    private var defaultEditActions: [IEditAnnotationAction] = {
        return [
            EditAnnotationAction(type: .settings),
            EditAnnotationAction(type: .delete)
        ]
    }()
    
    public var editActions: [IEditAnnotationAction] {
        return defaultEditActions
    }
    
    public var currentEditAction: IEditAnnotationAction?
        
    //MARK: - IEditableProperty
    
    public func reset() {
        coordinatesProperty.reset()
    }
    
    open func isValidEditableForSettings(_ editable: IEditable) -> Bool {
        return true
    }
    
    public var name: String {
        fatalError("Must be implemented in subclasses")
    }
}
