//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// StudyTooltipBase.swift is part of SCICHART®, High Performance Scientific Charts
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

open class StudyTooltipBase<TStudy: IStudy>: LinearStudyTooltipBase<TStudy> {
    
    public let titleLabel: StudyTooltipTitleLabel
    
    public init(study: TStudy, titleFontStyle: SCIFontStyle = Constants.defaultTooltipTitleFontStyle) {
        self.titleLabel = StudyTooltipTitleLabel(fontStyle: titleFontStyle)
        
        super.init(study: study)
        
        insertArrangedSubview(titleLabel, at: 0)
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func update() {
        updateTitleView(titleLabel: titleLabel)
    }
    
    open override func onShowSeriesTooltipsChanged(showSeriesTooltips: Bool) {}
    
    open func updateTitleView(titleLabel: UILabel) {
        titleLabel.text = study.name
    }
    
    open override func update(point: CGPoint) {
        updateTitleView(titleLabel: titleLabel)
    }
    
    public class StudyTooltipTitleLabel: UILabel {
        
        private let defaultPadding: CGFloat = 3
        
        init(fontStyle: SCIFontStyle) {
            super.init(frame: .zero)
            
            textColor = fontStyle.color
            font = UIFont(descriptor: fontStyle.fontDescriptor, size: fontStyle.fontDescriptor.pointSize)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func drawText(in rect: CGRect) {
            let rectWithPadding = rect.insetBy(dx: defaultPadding, dy: defaultPadding)

            super.drawText(in: rectWithPadding)
        }
        
        public override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize

            return CGSize(width: size.width + defaultPadding * 2, height: size.height + defaultPadding * 2)
        }
    }
}
