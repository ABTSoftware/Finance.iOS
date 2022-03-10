//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2022. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// FinanceLibDemoApp.swift is part of the SCICHART® FinanceLibDemo App. Permission is hereby granted
// to modify, create derivative works, distribute and publish any part of this source
// code whether for commercial, private or personal use.
//
// The SCICHART® FinanceLibDemo App is distributed in the hope that it will be useful, but
// without any warranty. It is provided "AS IS" without warranty of any kind, either
// expressed or implied.
//******************************************************************************

import SwiftUI
import SciChart

@main
struct FinanceLibDemoApp: App {
    
    init() {
        SCIChartSurface.setRuntimeLicenseKey("")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
