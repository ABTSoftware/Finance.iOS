//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2022. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// PropertyState.swift is part of SCICHART®, High Performance Scientific Charts
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

@objc open class PropertyState: NSObject, Codable {
    public override init() {
        super.init()
    }
    
    var values: [String: Any] = [:]
    
    enum CodingKeys: String, CodingKey {
        case values
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let data = try values.decode(Data.self, forKey: .values)
        self.values = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let data = try JSONSerialization.data(withJSONObject: values, options: [])
        try container.encode(data, forKey: .values)
    }
    
    public func write(property: String, value: Any) {
        values[property] = value
    }

    public func read(property: String) -> Any? {
        return values[property]
    }
}
