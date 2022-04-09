//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// MainChartContainer.swift is part of SCICHART®, High Performance Scientific Charts
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

open class DefaultChartContainer: UIView, IChartContainer {
    weak var chart: ISCIChartSurface?
    
    open func placeChart(_ chart: ISCIChartSurface) {
        self.chart = chart
        
        let chartView = chart.view
        addSubview(chartView)
        
        chartView.view.translatesAutoresizingMaskIntoConstraints = false
        
        chartView.view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        chartView.view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        chartView.view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        chartView.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumMainPaneHeight).isActive = true
    }
    
    open override var view: UIView {
        return self
    }
}

open class MainChartContainer: DefaultChartContainer {

    
}
