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
        
        let tileWidth = self.bounds.size.width
        let tileHeight = self.bounds.size.height
        
        let border = self.bounds.size.height / 8
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        UIColor.white.setFill()
        UIColor.white.setStroke()
        context.fill(self.bounds)
        context.stroke(self.bounds)
        
        let snakeColor = UIColor.init(hue: CGFloat(snakeHue), saturation: 0.5, brightness: 0.9, alpha: 1)
        
        if isWall {
            UIColor.black.setFill()
            UIColor.black.setStroke()
            context.fill(self.bounds)
            context.stroke(self.bounds)
            
        } else if isHead {
            
            let head = UIBezierPath()
            
            switch facing {
            case .Up:
                head.move(to: CGPoint(x: 0 + border, y: tileHeight))
                head.addLine(to: CGPoint(x: 0 + border, y: tileHeight / 2))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: 0 + border))
                head.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight / 2))
                head.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight))
            case .Right:
                head.move(to: CGPoint(x: 0 , y: 0 + border))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: 0 + border))
                head.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight / 2))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight - border))
                head.addLine(to: CGPoint(x: 0, y: tileHeight - border))
            case .Down:
                head.move(to: CGPoint(x: 0 + border, y: 0))
                head.addLine(to: CGPoint(x: tileWidth - border, y: 0))
                head.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight / 2))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight - border))
                head.addLine(to: CGPoint(x: 0 + border, y: tileHeight / 2))
            case .Left:
                head.move(to: CGPoint(x: tileWidth, y: tileHeight - border))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight - border))
                head.addLine(to: CGPoint(x: 0 + border, y: tileHeight / 2))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: 0 + border))
                head.addLine(to: CGPoint(x: tileWidth, y: 0 + border))
            }
            
            head.close()
            head.lineWidth = 1
            snakeColor.setFill()
            UIColor.black.setStroke()
            head.fill()
            head.stroke()
            
        } else if isBody {
            
            let body = UIBezierPath()
            
            func drawBodyUpRight() {
                body.move(to: CGPoint(x: 0 + border, y: 0))
                body.addLine(to: CGPoint(x: tileWidth - border, y: 0))
                body.addLine(to: CGPoint(x: tileWidth, y: 0 + border))
                body.addLine(to: CGPoint(x: tileWidth, y: tileHeight - border))
                body.addLine(to: CGPoint(x: (tileWidth / 2) + (border / 2), y: tileHeight - border))
                body.addLine(to: CGPoint(x: 0 + border, y: (tileHeight / 2) - (border / 2)))
            }
            
            func drawBodyUpDown() {
                body.move(to: CGPoint(x: 0 + border, y: 0))
                body.addLine(to: CGPoint(x: tileWidth - border, y: 0))
                body.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight))
                body.addLine(to: CGPoint(x: 0 + border, y: tileHeight))
            }
            
            func drawBodyUpLeft() {
                body.move(to: CGPoint(x: 0 + border, y: 0))
                body.addLine(to: CGPoint(x: tileWidth - border, y: 0))
                body.addLine(to: CGPoint(x: tileWidth - border, y: (tileHeight / 2) - (border / 2)))
                body.addLine(to: CGPoint(x: (tileWidth / 2) - (border / 2), y: tileHeight - border))
                body.addLine(to: CGPoint(x: 0, y: tileHeight - border))
                body.addLine(to: CGPoint(x: 0, y: 0 + border))
            }
            
            func drawBodyRightLeft() {
                body.move(to: CGPoint(x: 0, y: 0 + border))
                body.addLine(to: CGPoint(x: tileWidth, y: 0 + border))
                body.addLine(to: CGPoint(x: tileWidth, y: tileHeight - border))
                body.addLine(to: CGPoint(x: 0, y: tileHeight - border))
            }
            
            func drawBodyRightDown() {
                body.move(to: CGPoint(x: (tileWidth / 2) + (border / 2), y: 0 + border))
                body.addLine(to: CGPoint(x: tileWidth, y: 0 + border))
                body.addLine(to: CGPoint(x: tileWidth, y: tileHeight - border))
                body.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight))
                body.addLine(to: CGPoint(x: 0 + border, y: tileHeight))
                body.addLine(to: CGPoint(x: 0 + border, y: (tileHeight / 2) + (border / 2)))
            }
            
            func drawBodyDownLeft() {
                body.move(to: CGPoint(x: 0, y: 0 + border))
                body.addLine(to: CGPoint(x: (tileWidth / 2) - (border / 2), y: 0 + border))
                body.addLine(to: CGPoint(x: tileWidth - border, y: (tileHeight / 2) + (border / 2)))
                body.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight))
                body.addLine(to: CGPoint(x: 0 + border, y: tileHeight))
                body.addLine(to: CGPoint(x: 0, y: tileHeight - border))
            }
            
            let index = snake.firstIndex(of: self.tileID)
            
            switch facing {
            case .Up:
                if snake[index! + 1] == self.tileID + boardCol {
                    drawBodyUpRight()
                } else if snake[index! + 1] == self.tileID + boardRow {
                    drawBodyUpDown()
                } else {
                    drawBodyUpLeft()
                }
            case .Right:
                if snake[index! + 1] == self.tileID - boardRow {
                    drawBodyUpRight()
                } else if snake[index! + 1] == self.tileID - boardCol {
                    drawBodyRightLeft()
                } else {
                    drawBodyRightDown()
                }
            case .Down:
                if snake[index! + 1] == self.tileID + boardCol {
                    drawBodyRightDown()
                } else if snake[index! + 1] == self.tileID - boardCol {
                    drawBodyDownLeft()
                } else {
                    drawBodyUpDown()
                }
            case .Left:
                if snake[index! + 1] == self.tileID + boardRow {
                    drawBodyDownLeft()
                } else if snake[index! + 1] == self.tileID + boardCol {
                    drawBodyRightLeft()
                } else {
                    drawBodyUpLeft()
                }
            }
            
            snakeColor.setFill()
            UIColor.black.setStroke()
            body.close()
            body.fill()
            body.stroke()
        } else if isTail {
            
            let tail = UIBezierPath()
            
            switch facing {
            case .Up:
                tail.move(to: CGPoint(x: 0 + border, y: 0))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: 0))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight - border))
                tail.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight / 2))
                tail.addLine(to: CGPoint(x: 0 + border, y: tileHeight - border))
            case .Right:
                tail.move(to: CGPoint(x: 0 + border, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth, y: tileHeight - border))
                tail.addLine(to: CGPoint(x: 0 + border, y: tileHeight - border))
                tail.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight / 2))
            case .Down:
                tail.move(to: CGPoint(x: 0 + border, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight / 2))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight))
                tail.addLine(to: CGPoint(x: 0 + border, y: tileHeight))
            case .Left:
                tail.move(to: CGPoint(x: 0, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight / 2))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight - border))
                tail.addLine(to: CGPoint(x: 0, y: tileHeight - border))
            }
            
            tail.close()
            tail.lineWidth = 1
            snakeColor.setFill()
            UIColor.black.setStroke()
            tail.fill()
            tail.stroke()
            
        } else if isFruit {
            
            let fruit = UIBezierPath()
            fruit.move(to: CGPoint(x: tileWidth / 2, y: 0))
            fruit.addLine(to: CGPoint(x: tileWidth, y: tileHeight / 2))
            fruit.addLine(to: CGPoint(x: tileHeight / 2, y: tileHeight))
            fruit.addLine(to: CGPoint(x: 0, y: tileHeight / 2))
            fruit.addLine(to: CGPoint(x: tileWidth / 2, y: 0))
            fruit.close()
            fruit.lineWidth = 1
            let color = UIColor.init(hue: CGFloat(fruitHue), saturation: 1, brightness: 0.75, alpha: 1)
            color.setFill()
            UIColor.yellow.setStroke()
            fruit.fill()
            fruit.stroke()
            
        }
    }
}
