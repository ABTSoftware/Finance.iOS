//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2020. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// CrosshairModifier.swift is part of SCICHART®, High Performance Scientific Charts
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

import SciChart.Protected.SCICursorModifier

public class CrosshairModifier: SCITooltipModifierWithAxisLabelsBase, IGestureView, IPanePropertyContainer {
    public var crosshairPenStyle: SCIPenStyle {
        get { crosshairPenStyleProperty.value as! SCIPenStyle }
        set { crosshairPenStyleProperty.setStrongValue(newValue) }
    }

    private let studyLegend: StudyLegend
    private let axisTooltipsBehavior: SCIAxisTooltipsBehaviorBase<ISCIChartModifier>
    private let crosshairDrawableBehavior: CursorCrossHairDrawableBehaviour
    private let crosshairPenStyleProperty = SCISmartProperty()
    
    private var lastUpdatePointIsMaster = false
    private var hidesOnEnd = false
    private var shiftHelper: ShiftCrosshairHelper!
    
    convenience init(studyLegend: StudyLegend) {
        self.init(
            studyLegend: studyLegend,
            tooltipBehavior: TooltipBehaviour<CrosshairModifier>(modifierType: CrosshairModifier.self),
            crosshairDrawableBehavior: CursorCrossHairDrawableBehaviour(modifierType: CrosshairModifier.self)
        )
    }
    
    init(studyLegend: StudyLegend, tooltipBehavior: SCITooltipBehaviorBase<ISCIChartModifier>!, crosshairDrawableBehavior: CursorCrossHairDrawableBehaviour!) {
        self.studyLegend = studyLegend
        self.crosshairDrawableBehavior = crosshairDrawableBehavior
        self.axisTooltipsBehavior = AxisTooltipBehaviour(modifierType: CrosshairModifier.self)
        super.init(tooltipBehavior: tooltipBehavior, andAxisTooltipsBehavior: axisTooltipsBehavior)
        
        crosshairPenStyle = SCISolidPenStyle(color: .line, thickness: Colors.lightThickness, strokeDashArray: [5, 5])
    }
    
    public var gestureView: UIView? {
        didSet {
            replaceModifierOnGestureView()
        }
    }
    
    public override func attach(to services: ISCIServiceContainer) {
        super.attach(to: services)
        
        guard let parentSurface = parentSurface else { return }
        
        shiftHelper = ShiftCrosshairHelper(surface: parentSurface)

        replaceModifierOnGestureView()
        
        SCIModifierBehavior<ISCIChartModifierCore>.attach(crosshairDrawableBehavior, toModifier: self, withIsEnabled: true)
    }
    
    public override func detach() {
        crosshairDrawableBehavior.detach()
        if let gesture = self.gestureRecognizer {
            self.gestureView?.removeGestureRecognizer(gesture)
        }
        
        super.detach()
    }
    
    public override func apply(_ themeProvider: ISCIThemeProvider) {
        super.apply(themeProvider)
        
        crosshairPenStyleProperty.setStrongValue(crosshairPenStyle)
        crosshairDrawableBehavior.apply(themeProvider)
    }
    
    public override func onIsEnabledChanged(_ isEnabled: Bool) {
        super.onIsEnabledChanged(isEnabled)
        
        onIsEnabledChangedInternal(isEnabled)
    }
    
    public func updateIfNeeded() {
        guard isEnabled else { return }
        
        if isEnabled,
           let args = createArgsWithLastUpdatePoint() {
            onGestureChanged(with: args)
        }
    }
    
    public override func onRenderSurfaceRendered(_ renderedMessage: SCIRenderedMessage!) {
        super.onRenderSurfaceRendered(renderedMessage)
        
        updateIfNeeded()
    }
    
    public func normilizeLastUpdatedPoint() {
        shiftHelper.normilizeLastUpdatedPoint()
        updateIfNeeded()
    }
    
    private func onIsEnabledChangedInternal(_ isEnabled: Bool) {
        if isEnabled {
            hidesOnEnd = false
            
            if let args = createArgsWithLastUpdatePoint() {
                onGestureBegan(with: args)
            }
        } else {
            hidesOnEnd = true

            let args = SCIGestureModifierEventArgs()
            args.location = shiftHelper.lastUpdatedPoint
            
            onGestureEnded(with: args)
        }
    }
    
    private func createArgsWithLastUpdatePoint() -> SCIGestureModifierEventArgs? {
        guard let gestureView = gestureView,
              let parentSurface = parentSurface
        else { return nil }
        
        let args = SCIGestureModifierEventArgs()
        
        if shiftHelper.lastUpdatedPoint == .zero {
            shiftHelper.lastUpdatedPoint = CGPoint(
                x: parentSurface.modifierSurface.frame.size.width * CrosshairModifier.defaultLastPointRatio,
                y: parentSurface.modifierSurface.frame.size.height * CrosshairModifier.defaultLastPointRatio
            )
            let translatedPoint = gestureView.translate(shiftHelper.lastUpdatedPoint, hitTestable: parentSurface)
            args.isMaster = parentSurface.isPoint(withinBounds: translatedPoint, hitTestable: parentSurface)
            args.location = translatedPoint
        } else {
            args.isMaster = lastUpdatePointIsMaster
            args.location = shiftHelper.lastUpdatedPoint
        }
        
        return args
    }
    
    public override func onEvent(_ args: SCIGestureModifierEventArgs) {
        guard parentSurface != nil,
              let gestureRecognizer = args.gestureRecognizer else {
            super.onEvent(args)
            
            return
        }
        
        let canExecute = isEnabled && args.isInSourceBounds
        
        if canExecute {
            switch (gestureRecognizer.state) {
            case .began:
                onGestureBegan(with: args)
            case .changed:
                onGestureChanged(with: args)
            case .ended:
                onGestureEnded(with: args)
            case .cancelled:
                onGestureCancelled(with: args)
            default:
                break
            }
        }
    }
    
    public override func onGestureBegan(with args: SCIGestureModifierEventArgs) {
        if lastUpdatePointIsMaster != args.isMaster {
            lastUpdatePointIsMaster = args.isMaster
            onMasterChange(with: args)
        }
        
        lastUpdatePointIsMaster = args.isMaster
        
        shiftHelper.lastTouchPoint = args.location
        shiftHelper.updateArgsLocation(args: args)
        
        super.onGestureBegan(with: args)
        
        crosshairDrawableBehavior.onBeginUpdate(with: args)
        studyLegend.tryUpdateTooltips(point: args.location)
    }
    
    public override func onGestureChanged(with args: SCIGestureModifierEventArgs) {
        if lastUpdatePointIsMaster != args.isMaster {
            lastUpdatePointIsMaster = args.isMaster
            onMasterChange(with: args)
            
            shiftHelper.lastTouchPoint = args.location
            shiftHelper.updateArgsLocation(args: args)
            
            return
        }
        
        lastUpdatePointIsMaster = args.isMaster
                
        shiftHelper.updateArgsLocation(args: args)

        super.onGestureChanged(with: args)
        
        crosshairDrawableBehavior.onUpdate(with: args)
        studyLegend.tryUpdateTooltips(point: args.location)
    }
    
    private func onMasterChange(with args: SCIModifierEventArgs) {
        if lastUpdatePointIsMaster {
            shiftHelper.lastUpdatedPoint = CGPoint(x: shiftHelper.lastUpdatedPoint.x, y: args.location.y)
        }
        
        axisTooltipsBehavior.clear()
    }
    
    public override func onGestureEnded(with args: SCIGestureModifierEventArgs) {
        guard hidesOnEnd else { return }
        
        super.onGestureEnded(with: args)
        
        crosshairDrawableBehavior.onEndUpdate(with: args)
        studyLegend.tryUpdateTooltips(point: shiftHelper.lastUpdatedPoint)
        
        shiftHelper.lastTouchPoint = .zero
    }
    
    public override func clearAll() {
        super.clearAll()
        
        crosshairDrawableBehavior.clear()
    }
    
    public func savePropertyStateTo(chartState: PropertyState, paneState: PropertyState) {}
    public func restorePropertyStateFrom(chartState: PropertyState, paneState: PropertyState) {}
    
    private static let defaultLastPointRatio: CGFloat = 0.5
}
