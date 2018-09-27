//
//  ViewController.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 26/09/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

let BOARDSIZE = 36
let GAMESPEED = 0.1

enum Direction {
    case Up
    case Right
    case Down
    case Left
}

class ViewController: UIViewController {
    var gameTimer = Timer()
    var tileSize: CGFloat = 0.0, yPos: CGFloat = 0.0
    var newDirection: Direction = Direction.Right
    var headPos = 0, tailPos = 0, fruitPos = 0, snakeLength = 0, moves = 0, boardCol = 0, boardRow = 0, routeID = 0
    var isPaused = false
    var upSafe = false, rightSafe = false, downSafe = false, leftSafe = false
    var gameBoard = [BoardTile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardCol = Int(sqrt(Double(BOARDSIZE)))
        boardRow = 1
        tileSize = self.view.bounds.size.width / CGFloat(boardCol)
        yPos = self.view.bounds.height / 5
        newGame()
    }
    
    func newGame() {
        
        // Fill the gameBoard with BoardTiles:
        var i = 0
        for x in 0..<boardCol {
            for y in 0..<boardCol {
                let tile = BoardTile(frame: CGRect(x: CGFloat(x) * tileSize, y: (CGFloat(y) * tileSize) + yPos, width: tileSize, height: tileSize))
                tile.tileCol = x
                tile.tileRow = y
                
                // Set the BoardTile type:
                if y == 0 || x == 0 || x == boardCol - 1 || y == boardCol - 1 {
                    tile.isWall = true
                }
                
                gameBoard.append(tile)
                self.view.addSubview(tile)
                tile.tileID = i
                i += 1
            }
        }
        
        // Add the snake:
        headPos = (boardCol * 3) + (boardRow * 1)
        tailPos = headPos - (boardCol * 2)
        
        gameBoard[headPos].isHead = true
        gameBoard[headPos].facing = newDirection
        gameBoard[headPos - boardCol].isBody = true
        gameBoard[headPos - boardCol].facing = newDirection
        gameBoard[tailPos].isTail = true
        gameBoard[tailPos].facing = newDirection
        snakeLength = 3
        
        newFruit()
        
        view.setNeedsDisplay()
    }
    
    // Add a new fruit to the board:
    func newFruit() {
        gameBoard[headPos].isFruit = false
        routeID = gameBoard[headPos].tileID
        
        // Only add a new fruit if there is still space on the board:
        if snakeLength < (BOARDSIZE - (boardCol * 4) - 4) {
            var isSet = false
            while !isSet {
                let i = Int(arc4random()) % BOARDSIZE
                
                // Only add the fruit if the tile is free:
                if !gameBoard[i].isWall && !gameBoard[i].isHead && !gameBoard[i].isBody && !gameBoard[i].isTail {
                    gameBoard[i].isFruit = true
                    gameBoard[i].setNeedsDisplay()
                    fruitPos = i
                    isSet = true
                }
            }
        } else {
            //TODO: Add victory screen
        }
    }
}
