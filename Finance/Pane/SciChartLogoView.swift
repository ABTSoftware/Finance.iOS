//******************************************************************************
// SCICHART® Copyright SciChart Ltd. 2011-2021. All rights reserved.
//
// Web: http://www.scichart.com
// Support: support@scichart.com
// Sales:   sales@scichart.com
//
// SciChartLogoView.swift is part of SCICHART®, High Performance Scientific Charts
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

public class SciChartLogoView: UIView {
    private var isExpanded = false
    
    public init() {
        super.init(frame: .zero)
        
        placeMainStackView()
        logoText.alpha = isExpanded ? 1 : 0
        logoText.isHidden = !isExpanded
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func place(on superview: UIView, relatedTo: UIView? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        superview.addSubview(self)
        
        let relatedView = relatedTo ?? superview
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: relatedView.leadingAnchor, constant: 7),
            self.bottomAnchor.constraint(equalTo: relatedView.bottomAnchor, constant: -4),
        ])
    }
    
    private func placeMainStackView() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        
        let constant: CGFloat = 3
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -constant),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant),
        ])
    }
    
    private lazy var mainStackView: UIStackView = {
        let logoButton = UIButton()
        
        if let bundle = Bundle.finance {
            logoButton.setImage(UIImage(named: "scichart_logo", from: bundle), for: .normal)
        }
        
        logoButton.addTarget(self, action: #selector(onTap))
        
        let stackView = UIStackView(arrangedSubviews: [
            logoButton,
            logoText
        ])
        
        stackView.spacing = 3
        stackView.alignment = .center
        
        stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
        
        return stackView
    }()
    
    private lazy var logoText: UIStackView = {
        let sciChartStackView = UIStackView(arrangedSubviews: [
            LogoLabel(text: "SciChart".uppercased(), size: 23),
            LogoLabel(text: "®", size: 16),
        ])
        sciChartStackView.alignment = .top
        
        let stackView = UIStackView(arrangedSubviews: [
            LogoLabel(text: "powered by", size: 9),
            sciChartStackView
        ])
        
        stackView.spacing = -3
        stackView.axis = .vertical
        stackView.alignment = .leading
        
        return stackView
    }()
    
    @objc private func onTap() {
        isExpanded.toggle()
        
        let animationDuration = 0.2
        
        if isExpanded {
            logoText.isHidden = false
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.logoText.alpha = 1
            })
        } else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.logoText.alpha = 0
            }, completion: { _ in
                self.logoText.isHidden = true
            })
        }
        
        selectionHapticFeedback()
    }
    
    private class LogoLabel: UILabel {
        init(text: String, size: CGFloat) {
            super.init(frame: .zero)
            
            UIFont.registerFont(name: UIFont.neuropolFontName, bundle: .finance)
            
            self.text = text
            self.font = .neuropol(size: size)
            
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 1.0
            self.layer.shadowOpacity = 1.0
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
            self.layer.masksToBounds = false
            
            adjustsFontForContentSizeCategory = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
