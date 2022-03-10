//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// SecondaryChartContainer.swift is part of SCICHART®, High Performance Scientific Charts
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

class SecondaryChartContainer: MainChartContainer, IResizingView, UIGestureRecognizerDelegate {
    weak var pane: IPane?
    
    init(pane: IPane) {
        self.pane = pane
        
        super.init(frame: .zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onViewWillTransitionNotification(_:)), name: .viewWillTransitionNotification, object: nil)
        
        (self.pane?.xAxis as? FinanceDateXAxis)?.onSizeChange = { [weak self] size in
            guard let self = self else { return }
            
            if size.height != self.xAxisHeight {
                self.xAxisHeight = size.height
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var viewForDetectResizing: UIView = createViewForDetectResizing()
    lazy var separatorLine: UIView = createSeparatorLine()
    lazy var resizingLine: UIView = createResizingLine()
    lazy var paneHeightConstraint: NSLayoutConstraint = createPaneHeightConstraint()
    var xAxisHeight: CGFloat = 0 {
        didSet {
            updateHeightConstraint(screenHeight: UIScreen.main.bounds.size.height)
        }
    }
    
    var paneHeightRatioKey: String {
        return "\(pane?.paneId.id ?? "")+paneHeightRatio"
    }
    
    lazy var paneHeightRatio: CGFloat = backwardCompatibilityPaneHeightRatio ?? Constants.defaultSecondaryPaneHeightRatio
    
    private var backwardCompatibilityPaneHeightRatio: CGFloat? {
        UserDefaults.standard.object(forKey: paneHeightRatioKey) as? CGFloat
    }
    
    var cachedPaneHeight: CGFloat = Constants.minimumSecondaryPaneHeight
    lazy var pan = createPanGesture()
    var resizingState: ResizingState = .off
    
    var canResizeUp: Bool {
        guard
            let superView = self.superview as? UIStackView,
            let mainPaneView = superView.arrangedSubviews.first
        else {
            return true
        }
        
        return mainPaneView.frame.height > superView.frame.height / 3
    }
    
    @objc func onLongPress(_ gesture: UILongPressGestureRecognizer) {
        onLongPressAction(gesture)
    }
    
    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        onPanAction(gesture)
    }
    
    @objc private func onViewWillTransitionNotification(_ notification: Notification) {
        if let size = notification.userInfo?["size"] as? CGSize {
            updateHeightConstraint(screenHeight: size.height)
        }
    }
    
    override func placeChart(_ chart: ISCIChartSurface) {
        super.placeChart(chart)
        
        placeViewForDetectResizing()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        updateHeightConstraint(screenHeight: UIScreen.main.bounds.size.height)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func onPaneHeightRatioChange(_ paneHeightRatio: CGFloat) {
        pane?.onPaneHeightRatioChange(paneHeightRatio)
    }
}
