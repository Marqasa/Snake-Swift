//
//  BoardTile.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 26/09/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

class TileView: UIView {
    var tile = Tile()
    
    override func draw(_ rect: CGRect) {
        
        let tileWidth = self.bounds.size.width
        let tileHeight = self.bounds.size.height
        
        let border = self.bounds.size.height / 8
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        UIColor.white.setFill()
        UIColor.white.setStroke()
        context.fill(self.bounds)
        context.stroke(self.bounds)
        
        switch tile.kind {
        case .wall:
            
            UIColor.black.setFill()
            UIColor.gray.setStroke()
            context.fill(self.bounds)
            context.stroke(self.bounds)
            
        case let .head(direction, color):
            
            let head = UIBezierPath()
            
            switch direction {
            case .up:
                head.move(to: CGPoint(x: 0 + border, y: tileHeight))
                head.addLine(to: CGPoint(x: 0 + border, y: tileHeight / 2))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: 0 + border))
                head.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight / 2))
                head.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight))
            case .right:
                head.move(to: CGPoint(x: 0 , y: 0 + border))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: 0 + border))
                head.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight / 2))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight - border))
                head.addLine(to: CGPoint(x: 0, y: tileHeight - border))
            case .down:
                head.move(to: CGPoint(x: 0 + border, y: 0))
                head.addLine(to: CGPoint(x: tileWidth - border, y: 0))
                head.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight / 2))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight - border))
                head.addLine(to: CGPoint(x: 0 + border, y: tileHeight / 2))
            case .left:
                head.move(to: CGPoint(x: tileWidth, y: tileHeight - border))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight - border))
                head.addLine(to: CGPoint(x: 0 + border, y: tileHeight / 2))
                head.addLine(to: CGPoint(x: tileWidth / 2, y: 0 + border))
                head.addLine(to: CGPoint(x: tileWidth, y: 0 + border))
            }
            
            head.close()
            head.lineWidth = 1
            color.setFill()
            UIColor.black.setStroke()
            head.fill()
            head.stroke()
            
        case let .body(_, bodyShape, bodyColor):
            
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
            
            switch bodyShape {
            case .upRight:
                drawBodyUpRight()
            case .upDown:
                drawBodyUpDown()
            case .upLeft:
                drawBodyUpLeft()
            case .rightDown:
                drawBodyRightDown()
            case .rightLeft:
                drawBodyRightLeft()
            case .downLeft:
                drawBodyDownLeft()
            }
            
            bodyColor.setFill()
            UIColor.black.setStroke()
            body.close()
            body.fill()
            body.stroke()
            
        case let .tail(direction, color):
            
            let tail = UIBezierPath()
            
            switch direction {
            case .up:
                tail.move(to: CGPoint(x: 0 + border, y: 0))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: 0))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight - border))
                tail.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight / 2))
                tail.addLine(to: CGPoint(x: 0 + border, y: tileHeight - border))
            case .right:
                tail.move(to: CGPoint(x: 0 + border, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth, y: tileHeight - border))
                tail.addLine(to: CGPoint(x: 0 + border, y: tileHeight - border))
                tail.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight / 2))
            case .down:
                tail.move(to: CGPoint(x: 0 + border, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight / 2))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight))
                tail.addLine(to: CGPoint(x: 0 + border, y: tileHeight))
            case .left:
                tail.move(to: CGPoint(x: 0, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: 0 + border))
                tail.addLine(to: CGPoint(x: tileWidth / 2, y: tileHeight / 2))
                tail.addLine(to: CGPoint(x: tileWidth - border, y: tileHeight - border))
                tail.addLine(to: CGPoint(x: 0, y: tileHeight - border))
            }
            
            tail.close()
            tail.lineWidth = 1
            color.setFill()
            UIColor.black.setStroke()
            tail.fill()
            tail.stroke()
            
        case .fruit(let color):
            
            let fruit = UIBezierPath()
            fruit.move(to: CGPoint(x: tileWidth / 2, y: 0))
            fruit.addLine(to: CGPoint(x: tileWidth, y: tileHeight / 2))
            fruit.addLine(to: CGPoint(x: tileHeight / 2, y: tileHeight))
            fruit.addLine(to: CGPoint(x: 0, y: tileHeight / 2))
            fruit.addLine(to: CGPoint(x: tileWidth / 2, y: 0))
            fruit.close()
            fruit.lineWidth = 1
            color.setFill()
            UIColor.yellow.setStroke()
            fruit.fill()
            fruit.stroke()
            
        default:
            break
        }
    }
}
