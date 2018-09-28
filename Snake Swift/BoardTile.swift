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
        UIColor.white.setFill()
        UIColor.white.setStroke()
        context.fill(self.bounds)
        context.stroke(self.bounds)
        
        if isWall {
            UIColor.black.setFill()
            UIColor.black.setStroke()
            context.fill(self.bounds)
            context.stroke(self.bounds)
            
        } else if isHead {
            
            let head = UIBezierPath()
            
            switch facing {
            case .Up:
                head.move(to: CGPoint(x: 0, y: self.bounds.size.height))
                head.addLine(to: CGPoint(x: 0, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: 0))
                head.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
            case .Right:
                head.move(to: CGPoint(x: 0, y: 0))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: 0))
                head.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height))
                head.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
            case .Down:
                head.move(to: CGPoint(x: self.bounds.size.width, y: 0))
                head.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height))
                head.addLine(to: CGPoint(x: 0, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: 0, y: 0))
            case .Left:
                head.move(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height))
                head.addLine(to: CGPoint(x: 0, y: self.bounds.size.height / 2))
                head.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: 0))
                head.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
            }
            
            head.close()
            head.lineWidth = 1
            UIColor.red.setFill()
            UIColor.black.setStroke()
            head.fill()
            head.stroke()
            
        } else if isBody {
            
            UIColor.red.setFill()
            UIColor.black.setStroke()
            context.fill(self.bounds)
            context.stroke(self.bounds)
            
        } else if isTail {
            
            let tail = UIBezierPath()
            
            tail.move(to: CGPoint(x: 0, y: 0))
            
            switch facing {
            case .Up:
                tail.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
                tail.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
                tail.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2))
                tail.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
            case .Right:
                tail.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
                tail.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
                tail.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
                tail.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2))
            case .Down:
                tail.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2))
                tail.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
                tail.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
                tail.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
            case .Left:
                tail.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
                tail.addLine(to: CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2))
                tail.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
                tail.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
            }
            
            tail.close()
            tail.lineWidth = 1
            UIColor.red.setFill()
            UIColor.black.setStroke()
            tail.fill()
            tail.stroke()
            
        } else if isFruit {
            
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
            
        }
    }
}
