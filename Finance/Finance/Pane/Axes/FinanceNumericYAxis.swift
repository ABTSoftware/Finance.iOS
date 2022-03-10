//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FinanceNumericYAxis.swift is part of SCICHART®, High Performance Scientific Charts
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
import SciChart.Protected.SCIAxisCore
import SciChart.Protected.SCIAxisBase
import SciChart.Protected.SCIRangeCalculationHelper2DBase
import SciChart.Protected.SCIDefaultAxisInfoProvider

open class FinanceNumericYAxis: FinanceYAxisBase<SCINumericAxis> {
    
    public override init(
        name: String,
        axisId: AxisId,
        textFormatting: String = SCINumericAxis.defaultTextFormatting(),
        cursorTextFormatting: String = SCINumericAxis.defaultTextFormatting()
    ) {
        super.init(
            name: name,
            axisId: axisId,
            textFormatting: textFormatting,
            cursorTextFormatting: cursorTextFormatting
        )
    }
    
    open override func createAxis() -> SCINumericAxis {
        let axis = FinanceNumericAxis()
        axis.autoRange = .always
        axis.growBy = SCIDoubleRange(min: 0.2, max: 0.2)
        axis.maxAutoTicks = 5
        
        return axis
    }
    
    open class FinanceNumericAxis: SCINumericAxis {
        
        init() {
            super.init(defaultNonZeroRange: SCIDoubleRange(min: 0, max: 10), axisModifierSurface: SCIAxisModifierSurface())
            
            self.setRangeCalculationHelper(FinanceRangeCalculationHelper())
        }
        
        open override func onIsPrimaryAxisChanged(_ isPrimaryAxis: Bool) {
            super.onIsPrimaryAxisChanged(isPrimaryAxis)
            
            isVisible = isPrimaryAxis
        }
    }
    
    open class FinanceRangeCalculationHelper: SCINumericRangeCalculationHelper {
        open override func isValidSeries(_ rSeries: ISCIRenderableSeries, forYAxisWithId yAxisId: String) -> Bool {
            if let axis = self.axis {
                let axisId = AxisId.fromString(axisId: axis.axisId)
                let rsYAxisID = AxisId.fromString(axisId: rSeries.yAxisId)
                
                return FinanceNumericYAxis.shouldShareVisibleRange(thisId: axisId, thatId: rsYAxisID) && rSeries.isVisible && rSeries.isValidForUpdate
            }
            
            return false
        }
    }
    
    class FinanceNumericAxisInfoProvider: SCIDefaultAxisInfoProvider {
        override func getAxisTooltipInternal(_ axisInfo: SCIAxisInfo, modifierType: AnyClass) -> ISCIAxisTooltip {
            if modifierType == CrosshairModifier.self {
                return FinanceNumericAxisTooltip(axisInfo: axisInfo)
            } else {
                return super.getAxisTooltipInternal(axisInfo, modifierType: modifierType)
            }
        }
    }
    
    class FinanceNumericAxisTooltip: FinanceAxisTooltipBase {
        
        override var horizontalPadding: CGFloat { 10 }
        
        override func preventTooltipFromClipping() {
            var tooltipCenterX = view.center.x
            let tooltipHalfWidth = view.frame.size.width / 2
            let axisWidth = axis.axisModifierSurface.view.frame.size.width
            
            if tooltipCenterX < tooltipHalfWidth {
                tooltipCenterX = tooltipHalfWidth
            } else if tooltipCenterX > axisWidth - tooltipHalfWidth {
                tooltipCenterX = axisWidth - tooltipHalfWidth
            }

            view.center = CGPoint(x: tooltipCenterX, y: view.center.y)
        }
    }
}
