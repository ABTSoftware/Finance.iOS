//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// IPane.swift is part of SCICHART®, High Performance Scientific Charts
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

@objc public protocol IPane: IPanePropertyContainer {
    var rootView: UIView { get }
    var paneId: PaneId { get }
    var chart: ISCIChartSurface { get }
    var xAxis: ISCIAxis { get }

    var isCursorEnabled: Bool { get set }

    var chartTheme: SCIChartTheme { get set }
    var isXAxisVisible: Bool { get set }
    var isLogoVisible: Bool { get set }
    var isExpandButtonEnabled: Bool { get set }

    var chartContainer: IChartContainer { get }
    
    var delegate: PaneDelegate? { get set }

    func placeInto(financeChart: ISciFinanceChart)
    func removeFrom(financeChart: ISciFinanceChart)

    func addStudy(study: IStudy)
    func removeStudy(study: IStudy)

    var hasStudies: Bool { get }

    func onStudyChanged(studyId: StudyId)
    
    func onExpandAnimationStart()
    func onExpandAnimationFinish()
    
    func onResize(axisViewportDimension: CGFloat)
    
    func onPaneHeightRatioChange(_ paneHeightRatio: CGFloat)
}
