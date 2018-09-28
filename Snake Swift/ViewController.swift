//
//  ViewController.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 26/09/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

let BOARDSIZE = 512
let GAMESPEED = 0.5

enum Direction {
    case Up
    case Right
    case Down
    case Left
}

class ViewController: UIViewController {
    var gameTimer = Timer()
    var tileSize: CGFloat = 0.0, yPos: CGFloat = 0.0
    var newDirection: Direction = .Right
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
        
        // Add a new fruit
        newFruit()
        
        // Start the game
        gameTimer = Timer.scheduledTimer(withTimeInterval: GAMESPEED, repeats: true) { timer in
            self.gameLoop()
        }
        
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
            moves = 0
        } else {
            //TODO: Add victory screen
        }
    }
    
    // The game loop:
    func gameLoop() {
        moveTile(tile: headPos, direction: newDirection)
        
        
        //            [self fruitAI];
        //            [self collisionAI];
        
    }
    
    // Move tile with direction:
    func moveTile(tile: Int, direction: Direction) {
        var hasMoved = false
        
        // Head:
        if gameBoard[tile].isHead && !gameBoard[tile].isTail && !hasMoved {
            
            // Make a note of the current direction before setting a new direction:
            let oldDirection = gameBoard[tile].facing
            gameBoard[tile].facing = direction
            
            // Update head position based on direction:
            switch (direction) {
            case .Up:
                headPos = tile - boardRow
                break
            case .Right:
                headPos = tile + boardCol
                break
            case .Down:
                headPos = tile + boardRow
                break
            case .Left:
                headPos = tile - boardCol
                break
            }
            
            gameBoard[headPos].isHead = true
            moves += 1
            
            // Check for game over:
            if gameBoard[headPos].isBody || gameBoard[headPos].isWall {
                gameOver()
            }
            
            gameBoard[headPos].facing = direction
            gameBoard[headPos].setNeedsDisplay()
            gameBoard[tile].isHead = false
            
            // Move next tile:
            switch (oldDirection) {
            case .Up:
                moveTile(tile: tile + boardRow, direction: .Up)
                break
            case .Right:
                moveTile(tile: tile - boardCol, direction: .Right)
                break
            case .Down:
                moveTile(tile: tile - boardRow, direction: .Down)
                break
            case .Left:
                moveTile(tile: tile + boardCol, direction: .Left)
                break
            }
            
            // Mark tile as moved to avoid moving it twice:
            hasMoved = true
        }
        
        // Body:
        if gameBoard[tile].isBody && !hasMoved {
            let oldDirection = gameBoard[tile].facing
            gameBoard[tile].facing = direction
            
            var bodyPos = 0;
            switch (direction) {
            case .Up:
                bodyPos = tile - boardRow
                break
            case .Right:
                bodyPos = tile + boardCol
                break
            case .Down:
                bodyPos = tile + boardCol
                break
            case .Left:
                bodyPos = tile - boardCol
                break
            }
            
            gameBoard[bodyPos].isBody = true
            gameBoard[bodyPos].facing = direction
            gameBoard[bodyPos].setNeedsDisplay()
            gameBoard[tile].isBody = false
            
            switch (oldDirection) {
            case .Up:
                moveTile(tile: tile + boardRow, direction: .Up)
                break
            case .Right:
                moveTile(tile: tile - boardCol, direction: .Right)
                break
            case .Down:
                moveTile(tile: tile - boardRow, direction: .Down)
                break
            case .Left:
                moveTile(tile: tile + boardCol, direction: .Left)
                break
            }
            hasMoved = true
        }
        
        // Tail:
        if gameBoard[tile].isTail && !hasMoved {
            
            // If the snake eats a piece of fruit:
            if gameBoard[headPos].isFruit {
                
                gameBoard[tile].facing = direction
                
                // Add a new body tile and update snake length:
                var bodyPos = 0
                switch (direction) {
                case .Up:
                    bodyPos = tile - boardRow
                    break
                case .Right:
                    bodyPos = tile + boardCol
                    break
                case .Down:
                    bodyPos = tile + boardRow
                    break
                case .Left:
                    bodyPos = tile - boardCol
                    break
                }
                
                gameBoard[bodyPos].isBody = true
                gameBoard[bodyPos].facing = direction
                gameBoard[bodyPos].setNeedsDisplay()
                snakeLength += 1
                newFruit()
                
            } else {
                
                // Update tail position:
                switch (direction) {
                case .Up:
                    tailPos = tile - boardRow
                    break
                case .Right:
                    tailPos = tile + boardCol
                    break
                case .Down:
                    tailPos = tile + boardRow
                    break
                case .Left:
                    tailPos = tile - boardCol
                    break
                }
                
                gameBoard[tailPos].isTail = true
                gameBoard[tailPos].setNeedsDisplay()
                gameBoard[tile].isTail = false
                gameBoard[tile].setNeedsDisplay()
                
                // Only clear direction if the head is not directly behind the tail:
                if !gameBoard[tile].isHead {
                    gameBoard[tile].facing = .Up
                }
            }
        }
    }
    
    func gameOver() {
        print("Game Over")
        gameTimer.invalidate()
    }
}
