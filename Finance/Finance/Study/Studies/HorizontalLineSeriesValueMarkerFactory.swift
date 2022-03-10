//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// HorizontalLineSeriesValueMarkerFactory.swift is part of the SCICHART® SciTraider App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTraider App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import Foundation
import SciChart

public class HorizontalLineSeriesValueMarkerFactory: NSObject, ISCISeriesValueMarkerFactory {
    public var projectionFunction: CreateMarkerFunc
    
    public init(predicate: @escaping SCIPredicate = { _ in return true }) {
        projectionFunction = { series in
            return HorizontalLineSeriesValueMarker(renderableSeries: series, predicate: predicate)
        }
    }
}

import SciChart.Protected.SCISeriesValueMarkerBase
public class HorizontalLineSeriesValueMarker: SCISeriesValueMarkerBase {
    private var markerAnnotation: HorizontalLineSeriesValueMarkerAnnotation?
    
    public override func tryRemoveMarkerAnnotation(_ parentSurface: ISCIChartSurface) {
        if let markerAnnotation = markerAnnotation {
            parentSurface.annotations.remove(markerAnnotation)
        }
    }
    
    public override func tryAddMarkerAnnotation(_ parentSurface: ISCIChartSurface) {
        if let markerAnnotation = markerAnnotation {
            parentSurface.annotations.safeAdd(markerAnnotation)
        }
    }
    
    public override func createMarkerAnnotation() {
        markerAnnotation = HorizontalLineSeriesValueMarkerAnnotation(
            seriesValueHelper: HorizontalLineSeriesValueMarkerAnnotationHelper(
                renderableSeries: renderableSeries,
                predicate: isValidRenderableSeriesPredicate
            )
        )
        
        let label = SCIAnnotationLabel()
        label.labelPlacement = .axis
        markerAnnotation?.annotationLabels.add(label)
    }
    
    public override func destroyMarkerAnnotation() {
        markerAnnotation = nil
    }
}

import SciChart.Protected.SCIDefaultSeriesValueMarkerAnnotationHelper

public class HorizontalLineSeriesValueMarkerAnnotationHelper: SCIDefaultSeriesValueMarkerAnnotationHelper<HorizontalLineSeriesValueMarkerAnnotation> {
    private let lineThickness: Float = 1
    private let dashPattern: [NSNumber] = [4, 4]
    
    public override func updateAnnotation(annotation: HorizontalLineSeriesValueMarkerAnnotation, lastValue: ISCIComparable, lastColor: UIColor) {
        super.updateAnnotation(annotation: annotation, lastValue: lastValue, lastColor: lastColor)
        
        annotation.stroke = SCISolidPenStyle(color: lastColor, thickness: lineThickness, strokeDashArray: dashPattern)
        for i in 0..<annotation.annotationLabels.count {
            let label = annotation.annotationLabels[i]
            label.backgroundBrush = SCISolidBrushStyle(color: lastColor)
            label.fontStyle = SCIFontStyle(fontSize: 12, andTextColorCode: UIColor.getInvertedColor(lastColor.colorARGBCode()))
        }
    }
}

public class HorizontalLineSeriesValueMarkerAnnotation: SCIHorizontalLineAnnotation {
    private let seriesValueHelper: SCIDefaultSeriesValueMarkerAnnotationHelper<HorizontalLineSeriesValueMarkerAnnotation>
    
    public init(seriesValueHelper: SCIDefaultSeriesValueMarkerAnnotationHelper<HorizontalLineSeriesValueMarkerAnnotation>) {
        self.seriesValueHelper = seriesValueHelper
    }
    
    public override func attach(to services: ISCIServiceContainer) {
        let renderableSeries = seriesValueHelper.renderableSeries

        xAxisId = renderableSeries.xAxisId
        yAxisId = renderableSeries.yAxisId

        super.attach(to:services)
    }
    
    public override func update(withXAxis xAxis: ISCIAxis, yAxis: ISCIAxis) {
        seriesValueHelper.tryUpdateAnnotation(self)
        
        super.update(withXAxis: xAxis, yAxis: yAxis)
    }
}
