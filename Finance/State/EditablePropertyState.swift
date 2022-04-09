//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// EditablePropertyState.swift is part of SCICHART®, High Performance Scientific Charts
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

@objc open class EditablePropertyState: NSObject, Codable {
    public override init() {
        super.init()
    }
    
    var dictionary: [String: Any] = [:]
    
    enum CodingKeys: String, CodingKey {
        case dictionary
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let data = try values.decode(Data.self, forKey: .dictionary)
        dictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        try container.encode(data, forKey: .dictionary)
    }
    
    func savePropertyValue(parentName: String, propertyName: String, value: Any?) {
        let propertyId = propertyHash(parentName: parentName, propertyName: propertyName)
        dictionary[propertyId] = value
    }
    
    func savePropertyValues(editable: IEditable) {
        Mirror(reflecting: editable).reflectEditableProperties { (childItem: IEditable) in
            if let arrowHeadProperty = childItem as? ArrowHeadEditableProperty {
                savePropertyValue(parentName: editable.name, propertyName: arrowHeadProperty.name+"headLength", value: arrowHeadProperty.value.headLength)
                savePropertyValue(parentName: editable.name, propertyName: arrowHeadProperty.name+"headWidth", value: arrowHeadProperty.value.headWidth)
            }
            
            if let brushProperty = childItem as? BrushStyleEditableProperty {
                savePropertyValue(parentName: editable.name, propertyName: brushProperty.name+"colorCode", value: brushProperty.value.colorCode)
            }
            
            if let coordinateProperty = childItem as? CoordinatesEditableProperty {
                savePropertyValue(parentName: editable.name, propertyName: coordinateProperty.name+"x1", value: coordinateProperty.value.x1)
                savePropertyValue(parentName: editable.name, propertyName: coordinateProperty.name+"x2", value: coordinateProperty.value.x2)
                savePropertyValue(parentName: editable.name, propertyName: coordinateProperty.name+"y1", value: coordinateProperty.value.y1)
                savePropertyValue(parentName: editable.name, propertyName: coordinateProperty.name+"y2", value: coordinateProperty.value.y2)
            }
            
            if let doubleProperty = childItem as? DoubleEditableProperty {
                savePropertyValue(parentName: editable.name, propertyName: doubleProperty.name, value: doubleProperty.value)
            }
            
            if let floatProperty = childItem as? FloatEditableProperty {
                savePropertyValue(parentName: editable.name, propertyName: floatProperty.name, value: floatProperty.value)
            }
            
            if let fontProperty = childItem as? FontStyleEditableProperty {
                savePropertyValue(parentName: editable.name, propertyName: fontProperty.name+"fontSize", value: fontProperty.value.fontDescriptor.pointSize)
                savePropertyValue(parentName: editable.name, propertyName: fontProperty.name+"textColorCode", value: fontProperty.value.colorCode)
            }
            
            if let intProperty = childItem as? IntEditableProperty {
                savePropertyValue(parentName: editable.name, propertyName: intProperty.name, value: intProperty.value)
            }
            
            if let penProperty = childItem as? PenStyleEditableProperty {
                savePropertyValue(parentName: editable.name, propertyName: penProperty.name+"colorCode", value: penProperty.value.colorCode)
                savePropertyValue(parentName: editable.name, propertyName: penProperty.name+"thickness", value: penProperty.value.thickness)
                savePropertyValue(parentName: editable.name, propertyName: penProperty.name+"strokeDashArray", value: penProperty.value.strokeDashArray)
            }
            
            if let stringProperty = childItem as? StringEditableProperty {
                savePropertyValue(parentName: editable.name, propertyName: stringProperty.name, value: stringProperty.value)
            }
            
            if let dataSourceProperty = childItem as? DataSourceEditableProperty {
                savePropertyValue(parentName: editable.name, propertyName: dataSourceProperty.name+"id", value: dataSourceProperty.value.id)
            }
            
            if let ta_maTypeProperty = childItem as? TA_MAType_EditableProperty {
                savePropertyValue(parentName: editable.name, propertyName: ta_maTypeProperty.name, value: ta_maTypeProperty.value)
            }
        }
    }
    
    func tryGetPropertyValue(parentName: String, propertyName: String) -> Any? {
        let propertyId = propertyHash(parentName: parentName, propertyName: propertyName)
        
        return dictionary[propertyId]
    }
    
    func tryRestorePropertyValue(parentName: String, property: IEditableProperty) {
        if let arrowHead = property as? ArrowHeadEditableProperty {
            if let headLength = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"headLength") as? Float,
               let headWidth = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"headWidth") as? Float {
                arrowHead.trySetValue(ArrowHead(headLength: headLength, headWidth: headWidth))
            }
            return
        }
        
        if let brush = property as? BrushStyleEditableProperty {
            if let brushColorCode = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"colorCode") as? UInt32 {
                brush.trySetValue(SCISolidBrushStyle(color: brushColorCode))
            }
            return
        }
        
        if let coordinate = property as? CoordinatesEditableProperty {
            let x1 = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"x1") as? Double
            let x2 = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"x2") as? Double
            let y1 = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"y1") as? Double
            let y2 = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"y2") as? Double
            
            coordinate.trySetValue(AnnotationCoordinates(x1: x1, y1: y1, x2: x2, y2: y2))
            return
        }
        
        if let doubleProperty = property as? DoubleEditableProperty {
            if let value = tryGetPropertyValue(parentName: parentName, propertyName: property.name) as? Double {
                doubleProperty.trySetValue(value)
            }
            return
        }
        
        if let floatProperty = property as? FloatEditableProperty {
            if let value = tryGetPropertyValue(parentName: parentName, propertyName: property.name) as? Float {
                floatProperty.trySetValue(value)
            }
            return
        }
        
        if let font = property as? FontStyleEditableProperty {
            if let fontSize = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"fontSize") as? Float,
               let textColorCode = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"textColorCode") as? UInt32 {
                font.trySetValue(SCIFontStyle(fontSize: fontSize, andTextColorCode: textColorCode))
                return
            }
        }
        
        if let intProperty = property as? IntEditableProperty {
            if let value = tryGetPropertyValue(parentName: parentName, propertyName: property.name) as? Int {
                intProperty.trySetValue(value)
            }
            return
        }
        
        if let pen = property as? PenStyleEditableProperty {
            if let penColorCode = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"colorCode") as? UInt32,
               let thickness = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"thickness") as? Float,
               let strokeDashArray = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"strokeDashArray") as? [NSNumber]? {
                pen.trySetValue(SCISolidPenStyle(color: penColorCode, thickness: thickness, strokeDashArray: strokeDashArray, antiAliasing: true))
            }
            return
        }
        
        if let stringProperty = property as? StringEditableProperty {
            if let value = tryGetPropertyValue(parentName: parentName, propertyName: property.name) as? String {
                stringProperty.trySetValue(value)
            }
            return
        }
        
        if let ta_maTypeProperty = property as? TA_MAType_EditableProperty {
            if let value = tryGetPropertyValue(parentName: parentName, propertyName: property.name) as? Int {
                ta_maTypeProperty.trySetValue(value)
            }
        }
        
//        if let dataSource = property as? DataSourceEditableProperty {
//            if let id = tryGetPropertyValue(parentName: parentName, propertyName: property.name+"id") as? String {
//                dataSource.value = DataSourceId(id: id)
//                return dataSource
//            }
//        }
    }
    
    func tryRestorePropertyValues(editable: IEditable) {
        Mirror(reflecting: editable).reflectEditableProperties { child in
            tryRestorePropertyValue(parentName: editable.name, property: child)
        }
    }
    
    private func propertyHash(parentName: String, propertyName: String) -> String {
        return parentName + propertyName
    }
}
