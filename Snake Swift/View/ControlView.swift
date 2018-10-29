//
//  ControlView.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 28/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

class ControlView: UIView {
    private var upButton: UIBezierPath!
    private let upColor = UIColor(hue: 181, saturation: 0.75, brightness: 0.53, alpha: 0.5)
    private var rightButton: UIBezierPath!
    private let rightColor = UIColor(hue: 181, saturation: 0.75, brightness: 0.53, alpha: 0.5)
    private var downButton: UIBezierPath!
    private let downColor = UIColor(hue: 181, saturation: 0.75, brightness: 0.53, alpha: 0.5)
    private var leftButton: UIBezierPath!
    private let leftColor = UIColor(hue: 181, saturation: 0.75, brightness: 0.53, alpha: 0.5)
    var route = [Direction]()
    var imageView: UIView!
    let nibName = "ControlView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.nibName, bundle: bundle)
        imageView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        imageView.frame = bounds
        addSubview(imageView)
        
        upButton = UIBezierPath()
        upButton.move(to: bounds.origin)
        upButton.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2))
        upButton.addLine(to: CGPoint(x: bounds.width, y: 0))
        upButton.close()
        
        rightButton = UIBezierPath()
        rightButton.move(to: CGPoint(x: bounds.width, y: 0))
        rightButton.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2))
        rightButton.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        rightButton.close()
        
        downButton = UIBezierPath()
        downButton.move(to: CGPoint(x: bounds.width, y: bounds.height))
        downButton.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2))
        downButton.addLine(to: CGPoint(x: 0, y: bounds.height))
        downButton.close()
        
        leftButton = UIBezierPath()
        leftButton.move(to: CGPoint(x: 0, y: bounds.height))
        leftButton.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2))
        leftButton.addLine(to: bounds.origin)
        leftButton.close()
        alpha = 0.9
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            let pos = touch.preciseLocation(in: self)
            if upButton.contains(pos) { route.append(.up) }
            else if rightButton.contains(pos) { route.append(.right) }
            else if downButton.contains(pos) { route.append(.down) }
            else if leftButton.contains(pos) { route.append(.left) }
        }
    }
}
