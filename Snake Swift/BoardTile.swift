//
//  BoardTile.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 26/09/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

class BoardTile: UIView {
    var isHead = false, isBody = false, isTail = false, isFruit = false, isWall = false
    var upChecked = false, rightChecked = false, downChecked = false, leftChecked = false
    var facing = Direction.Up
    var tileCol = 0, tileRow = 0, tileID = 0
    
    override func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        var fill = true
        var stroke = true
        
        if isWall {
            UIColor.black.setFill()
            UIColor.black.setStroke()
            
        } else if isHead {
            UIColor.white.setFill()
            UIColor.white.setStroke()
            context.fill(self.bounds)
            context.stroke(self.bounds)
            fill = false
            stroke = false
            
            let head = UIBezierPath()
            
            if facing == Direction.Up {
                head.move(to: CGPoint(x: 0, y: self.bounds.size.height))
                head.addLine(to: CGPoint(x: 0, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: 0))
                head.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
            } else if facing == Direction.Right {
                head.move(to: CGPoint(x: 0, y: 0))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: 0))
                head.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height))
                head.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
            } else if facing == Direction.Down {
                head.move(to: CGPoint(x: self.bounds.size.width, y: 0))
                head.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height))
                head.addLine(to: CGPoint(x: 0, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: 0, y: 0))
            } else if (self.facing == Direction.Left) {
                head.move(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height))
                head.addLine(to: CGPoint(x: 0, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: 0))
                head.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
            }
            
            head.close()
            head.lineWidth = 1
            UIColor.red.setFill()
            UIColor.purple.setStroke()
            head.fill()
            head.stroke()
            
        } else if isBody || isTail {
            
            UIColor.red.setFill()
            UIColor.purple.setStroke()
            
        } else if isFruit {
            UIColor.white.setFill()
            UIColor.white.setStroke()
            context.fill(self.bounds)
            context.stroke(self.bounds)
            fill = false
            stroke = false
            
            let fruit = UIBezierPath()
            fruit.move(to: CGPoint(x: self.bounds.size.width / 2, y: 0))
            fruit.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height / 2))
            fruit.addLine(to: CGPoint(x: self.bounds.size.height / 2, y: self.bounds.size.height))
            fruit.addLine(to: CGPoint(x: 0, y: self.bounds.size.height / 2))
            fruit.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: 0))
            fruit.close()
            fruit.lineWidth = 1
            UIColor.green.setFill()
            UIColor.yellow.setStroke()
            fruit.fill()
            fruit.stroke()

        } else {
            
            UIColor.white.setFill()
            UIColor.white.setStroke()
            
        }
        
        if fill {
            context.fill(self.bounds)
        }
        if stroke {
            context.stroke(self.bounds)
        }
    }
}
