//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// IResizingView.swift is part of SCICHART®, High Performance Scientific Charts
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

@objc protocol ResizingViewSetuper {
    func onLongPress(_ gesture: UILongPressGestureRecognizer)
    func onPan(_ gesture: UIPanGestureRecognizer)
}

public enum ResizingState {
    case active, off
}

protocol IResizingView: ResizingViewSetuper where Self: MainChartContainer & UIGestureRecognizerDelegate {
    var canResizeUp: Bool { get }
    var canResizeDown: Bool { get }
    var viewForDetectResizing: UIView { get set }
    var separatorLine: UIView { get set }
    var resizingLine: UIView { get set }
    var paneHeightConstraint: NSLayoutConstraint { get }
    var pan: UIPanGestureRecognizer { get set }
    var resizingState: ResizingState { get set }
    
    var paneHeightRatioKey: String { get }
    var paneHeightRatio: CGFloat { get set }
    func updateHeightConstraint(screenHeight: CGFloat)
    var xAxisHeight: CGFloat { get set }
    var cachedPaneHeight: CGFloat { get set }
    
    func onPaneHeightRatioChange(_ paneHeightRatio: CGFloat)
}

extension IResizingView {
    func placeViewForDetectResizing() {
        viewForDetectResizing.translatesAutoresizingMaskIntoConstraints = false
        addSubview(viewForDetectResizing)
        
        NSLayoutConstraint.activate([
            viewForDetectResizing.leadingAnchor.constraint(equalTo: leadingAnchor),
            viewForDetectResizing.trailingAnchor.constraint(equalTo: trailingAnchor),
            viewForDetectResizing.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
    func createViewForDetectResizing() -> UIView {
        let view = HitTestView()
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: Constants.viewForDetectResizingHeight).isActive = true
        
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorLine)
        
        resizingLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resizingLine)
        resizingLine.isHidden = true
        
        NSLayoutConstraint.activate([
            paneHeightConstraint,
            separatorLine.heightAnchor.constraint(equalToConstant: Constants.separatorNotActiveHeight),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.topAnchor.constraint(equalTo: view.topAnchor),
            
            resizingLine.heightAnchor.constraint(equalToConstant: Constants.separatorActiveHeight),
            resizingLine.leadingAnchor.constraint(equalTo: separatorLine.leadingAnchor),
            resizingLine.trailingAnchor.constraint(equalTo: separatorLine.trailingAnchor),
            resizingLine.centerYAnchor.constraint(equalTo: separatorLine.centerYAnchor)
        ])
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ResizingViewSetuper.onLongPress(_:)))
        longPress.minimumPressDuration = 0
        view.addGestureRecognizer(longPress)
        
        pan.delegate = self
        view.addGestureRecognizer(pan)
        
        return view
    }
    
    func onLongPressAction(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            resizingState = .active
            updateSeparatorLine()
        case .ended, .cancelled, .failed:
            resizingState = .off
            updateSeparatorLine()
        default:
            break
        }
    }
    
    func updateSeparatorLine() {
        resizingLine.isHidden = resizingState == .off
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        view.selectionHapticFeedback()
    }
    
    func createSeparatorLine() -> UIView {
        let view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .separator
        } else {
            view.backgroundColor = .lightGray
        }
        
        return view
    }
    
    func createResizingLine() -> UIView {
        let gradient = GradientView()
        gradient.configureGradientLayer(colors: [UIColor.mainButtonStart, UIColor.mainButtonEnd])
        
        let resizeArrowsView = UIImageView(image: UIImage.ResizeArrows)
        resizeArrowsView.translatesAutoresizingMaskIntoConstraints = false
        gradient.addSubview(resizeArrowsView)
        
        NSLayoutConstraint.activate([
            resizeArrowsView.centerXAnchor.constraint(equalTo: gradient.centerXAnchor),
            resizeArrowsView.centerYAnchor.constraint(equalTo: gradient.centerYAnchor)
        ])

        return gradient
    }
    
    func createPaneHeightConstraint() -> NSLayoutConstraint {
        cachedPaneHeight = heightConstant(screenHeight: Constants.minimumSecondaryPaneHeight)
        let constraint = heightAnchor.constraint(equalToConstant: cachedPaneHeight)
        constraint.priority = .defaultHigh
        return constraint
    }
    
    func createPanGesture() -> UIPanGestureRecognizer {
        return UIPanGestureRecognizer(target: self, action: #selector(ResizingViewSetuper.onPan(_:)))
    }
    
    func onPanAction(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            if resizingState == .active {
                let translation = gesture.translation(in: self)
                let newHeight = max(cachedPaneHeight - translation.y, Constants.minimumSecondaryPaneHeight)
                let screenHeight = UIScreen.main.bounds.size.height
                paneHeightRatio = screenHeight / newHeight
                onPaneHeightRatioChange(paneHeightRatio)
                
                gesture.setTranslation(.zero, in: self)
                
                if newHeight > cachedPaneHeight && !canResizeUp || newHeight < cachedPaneHeight && !canResizeDown {
                    return
                }
                
                updateHeightConstraint(screenHeight: screenHeight)
            }
        default:
            break
        }
    }
    
    var canResizeDown: Bool {
        guard let chart = self.chart else { return false }
        
        let renderableSeriesAreaView = chart.renderableSeriesArea.view
        return renderableSeriesAreaView.frame.height > Constants.minimumSecondaryPaneHeight
    }
    
    private func heightConstant(screenHeight: CGFloat) -> CGFloat {
        return max(screenHeight / paneHeightRatio, Constants.minimumSecondaryPaneHeight)
    }
    
    func updateHeightConstraint(screenHeight: CGFloat) {
        cachedPaneHeight = heightConstant(screenHeight: screenHeight)
        paneHeightConstraint.constant = cachedPaneHeight + xAxisHeight
    }
}

class HitTestView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let frame = self.bounds.insetBy(dx: 0, dy: -Constants.viewForDetectResizingHeight)
        return frame.contains(point) ? self : nil;
    }
}
