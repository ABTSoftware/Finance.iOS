//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// SciAnnotationCreationModifier.swift is part of the SCICHART® SciTrader App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® SciTrader App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SciChart.Protected.SCIGestureModifierBase
import SciChart.Protected.SCIChartModifierBase

class SciAnnotationCreationModifier: SCIGestureModifierBase {
    
    private let coordinatePt2offset: CGFloat = 50
    
    var onCreateAnnotation: (Property<AnnotationCoordinates>) -> Void
    
    init(onCreateAnnotation: ( @escaping (Property<AnnotationCoordinates>) -> Void)) {
        self.onCreateAnnotation = onCreateAnnotation
        
        super.init()
    }
    
    override func createGestureRecognizer() -> UIGestureRecognizer {
        return SciTapDownGesture()
    }
    
    override func onGestureEnded(with args: SCIGestureModifierEventArgs) {
        guard let gesture = args.gestureRecognizer as? SciTapDownGesture else { return }
        
        onCreateAnnotation(getCoordinate(from: gesture))
    }
    
    private func getCoordinate(from gesture: UIGestureRecognizer) -> Property<AnnotationCoordinates> {
        guard let parentView = self.parentSurface?.modifierSurface.view else {
            return Property(initialValue: AnnotationCoordinates(x1: 0, y1: 0, x2: 0, y2: 0), defaultValue: AnnotationCoordinates(x1: 0, y1: 0, x2: 0, y2: 0))
        }
        
        let location = gesture.location(in: parentView)

        let xAxis = self.xAxes.defaultAxis
        let yAxis = self.yAxes.defaultAxis

        let xCalc = xAxis.currentCoordinateCalculator
        let yCalc = yAxis.currentCoordinateCalculator
        
        let coordinates = AnnotationCoordinates(x1: xCalc.getDataValue(Float(location.x)),
                                                y1: yCalc.getDataValue(Float(location.y)),
                                                x2: xCalc.getDataValue(Float(location.x + coordinatePt2offset)),
                                                y2: yCalc.getDataValue(Float(location.y + coordinatePt2offset)))
        
        return Property(initialValue: coordinates, defaultValue: coordinates)
    }
}
