//
//  UIView+Extensions.swift
//  EpayApp
//
//  Created by a1pamys on 3/21/20.
//  Copyright © 2020 Алпамыс. All rights reserved.
//

import UIKit

public extension UIView {
    
    public convenience init(color: UIColor) {
        let v = UIView()
        v.backgroundColor = color
        self.init()
    }
    
    func fillSuperview() {
        anchor(top: superview?.topAnchor, right: superview?.rightAnchor, left: superview?.leftAnchor, bottom: superview?.bottomAnchor)
    }
    
    func fillToEdges(padding: CGFloat) {
        anchor(top: superview?.topAnchor, right: superview?.rightAnchor, left: superview?.leftAnchor, bottom: superview?.bottomAnchor, paddingTop: padding, paddingRight: padding, paddingLeft: padding, paddingBottom: padding)
    }
    
    public func anchor(top: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingRight: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil,
                centerX: NSLayoutXAxisAnchor? = nil,
                centerY: NSLayoutYAxisAnchor? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX).isActive = true
        }
        
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }
}

