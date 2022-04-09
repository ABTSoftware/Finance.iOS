//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// StudyLegend.swift is part of SCICHART®, High Performance Scientific Charts
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

import UIKit
import SciChart

struct StudyTooltipsModel {
    let studyId: StudyId
    let studyTooltip: IStudyTooltip
}

public class StudyLegend: StackViewContainer {
    public init() {
        super.init(frame: .zero)
        
        axis = .vertical
        alignment = .leading
        spacing = 5
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var studyTooltips = [StudyTooltipsModel]()
    
    private var _showSeriesTooltips = false
    var showSeriesTooltips: Bool {
        get {
            return _showSeriesTooltips
        }
        
        set {
            if _showSeriesTooltips == newValue { return }
            
            _showSeriesTooltips = newValue
            for model in studyTooltips {
                model.studyTooltip.showSeriesTooltips = newValue
            }
        }
    }
    
    func onStudyChanged(studyId: StudyId) {
        studyTooltips.first(where: { $0.studyId == studyId })?.studyTooltip.update()
    }
    
    func removeTooltip(studyId: StudyId) {
        if let index = studyTooltips.firstIndex(where: { $0.studyId == studyId }) {
            studyTooltips[index].studyTooltip.remove(from: self)
            studyTooltips.remove(at: index)
        }
    }
        
    func addTooltip(studyTooltip: IStudyTooltip) {
        studyTooltips.append(StudyTooltipsModel(studyId: studyTooltip.studyId, studyTooltip: studyTooltip))

        studyTooltip.place(into: self)
        studyTooltip.update()
    }
    
    func tryUpdateTooltips(point: CGPoint) {
        for model in studyTooltips {
            model.studyTooltip.update(point: point)
        }
    }
    
    func tryUpdateTooltips() {
        for model in studyTooltips {
            model.studyTooltip.update()
        }
    }
}
