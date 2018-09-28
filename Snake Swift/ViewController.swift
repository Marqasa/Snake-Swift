//
//  ViewController.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 26/09/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

//TODO: Check BOARDSIZE is a perfect square
let BOARDSIZE = 49
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
    var headID = 0, tailID = 0, fruitID = 0, snakeLength = 0, moves = 0, boardCol = 0, boardRow = 0, routeID = 0
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
        headID = (boardCol * 3) + (boardRow * 1)
        tailID = headID - (boardCol * 2)
        
        gameBoard[headID].isHead = true
        gameBoard[headID].facing = newDirection
        gameBoard[headID - boardCol].isBody = true
        gameBoard[headID - boardCol].facing = newDirection
        gameBoard[tailID].isTail = true
        gameBoard[tailID].facing = newDirection
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
        gameBoard[headID].isFruit = false
        routeID = gameBoard[headID].tileID
        
        // Only add a new fruit if there is still space on the board:
        if snakeLength < (BOARDSIZE - (boardCol * 4) - 4) {
            var isSet = false
            while !isSet {
                let i = Int(arc4random()) % BOARDSIZE
                
                // Only add the fruit if the tile is free:
                if !gameBoard[i].isWall && !gameBoard[i].isHead && !gameBoard[i].isBody && !gameBoard[i].isTail {
                    gameBoard[i].isFruit = true
                    gameBoard[i].setNeedsDisplay()
                    fruitID = i
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
        moveTile(headID, newDirection)
        fruitAI()
        
        //            [self collisionAI];
        
    }
    
    // Move tile in direction:
    func moveTile(_ tileID: Int, _ direction: Direction) {
        var hasMoved = false
        
        // Head:
        if gameBoard[tileID].isHead && !gameBoard[tileID].isTail && !hasMoved {
            
            // Make a note of the current direction before setting a new direction:
            let oldDirection = gameBoard[tileID].facing
            gameBoard[tileID].facing = direction
            
            // Update head position with direction:
            headID = updateTileID(tileID, direction)
            gameBoard[headID].isHead = true
            
            // Check for game over:
            if gameBoard[headID].isBody || gameBoard[headID].isWall {
                gameOver()
                return
            }
            
            gameBoard[headID].facing = direction
            gameBoard[headID].setNeedsDisplay()
            gameBoard[tileID].isHead = false
            
            // Move the next tile in the snake:
            hasMoved = moveNextTile(tileID, oldDirection)
        }
        
        // Body:
        if gameBoard[tileID].isBody && !hasMoved {
            let oldDirection = gameBoard[tileID].facing
            gameBoard[tileID].facing = direction
            
            // Update body position with direction:
            let bodyID = updateTileID(tileID, direction)
            gameBoard[bodyID].isBody = true
            gameBoard[bodyID].facing = direction
            gameBoard[bodyID].setNeedsDisplay()
            gameBoard[tileID].isBody = false
            
            // Move the next tile in the snake:
            hasMoved = moveNextTile(tileID, oldDirection)
        }
        
        // Tail:
        if gameBoard[tileID].isTail && !hasMoved {
            
            // If the snake eats a piece of fruit:
            if gameBoard[headID].isFruit {
                
                // Add a new body tile, update snake length and create a new fruit:
                gameBoard[tileID].facing = direction
                let bodyID = updateTileID(tileID, direction)
                gameBoard[bodyID].isBody = true
                gameBoard[bodyID].facing = direction
                gameBoard[bodyID].setNeedsDisplay()
                snakeLength += 1
                newFruit()
                
            } else {
                
                // Update tail position with direction:
                tailID = updateTileID(tileID, direction)
                gameBoard[tailID].isTail = true
                gameBoard[tailID].setNeedsDisplay()
                gameBoard[tileID].isTail = false
                gameBoard[tileID].setNeedsDisplay()
                
                // Only clear direction if the head is not directly behind the tail:
                if !gameBoard[tileID].isHead {
                    gameBoard[tileID].facing = .Up
                }
            }
        }
    }
    
    // Return updated tileID:
    func updateTileID(_ tileID: Int, _ direction: Direction) -> Int {
        switch (direction) {
        case .Up:
            return tileID - boardRow
        case .Right:
            return tileID + boardCol
        case .Down:
            return tileID + boardRow
        case .Left:
            return tileID - boardCol
        }
    }
    
    // Move the next tile in the snake:
    func moveNextTile(_ tileID: Int, _ direction: Direction) -> Bool {
        switch (direction) {
        case .Up:
            moveTile(tileID + boardRow, .Up)
        case .Right:
            moveTile(tileID - boardCol, .Right)
        case .Down:
            moveTile(tileID - boardRow, .Down)
        case .Left:
            moveTile(tileID + boardCol, .Left)
        }
        return true
    }
    
    // A snake gotta eat!
    func fruitAI() {
        
        // Directly down:
        if gameBoard[fruitID].tileRow > gameBoard[headID].tileRow && gameBoard[fruitID].tileCol == gameBoard[headID].tileCol {
            
            // If not currently going up, go down:
            if gameBoard[headID].facing != .Up {
                newDirection = .Down
            } else {
                // Go either left or right:
                if arc4random_uniform(2) > 0 && !gameBoard[headID + boardCol].isWall {
                    newDirection = .Right
                } else {
                    newDirection = .Left
                }
            }
        }
        
        // Down right:
        if gameBoard[fruitID].tileRow > gameBoard[headID].tileRow && gameBoard[fruitID].tileCol > gameBoard[headID].tileCol {
            
            // Only change course if not already going down or right:
            if gameBoard[headID].facing != .Down && gameBoard[headID].facing != .Right {
                
                // Go either down or right:
                if gameBoard[headID].facing == .Left && gameBoard[headID + boardRow].isWall {
                    newDirection = .Down
                } else {
                    newDirection = .Right
                }
            }
        }
        
        // Directly right:
        if gameBoard[fruitID].tileRow == gameBoard[headID].tileRow && gameBoard[fruitID].tileCol > gameBoard[headID].tileCol {
            if gameBoard[headID].facing != .Left {
                newDirection = .Right
            } else {
                if arc4random_uniform(2) > 0 && !gameBoard[headID + boardRow].isWall {
                    newDirection = .Down
                } else {
                    newDirection = .Up
                }
            }
        }
        
        // Up right:
        if (gameBoard[fruitID].tileRow < gameBoard[headID].tileRow && gameBoard[fruitID].tileCol > gameBoard[headID].tileCol) {
            if gameBoard[headID].facing != .Right && gameBoard[headID].facing != .Up {
                if gameBoard[headID].facing == .Down && !gameBoard[headID + boardCol].isWall {
                    newDirection = .Right
                } else {
                    newDirection = .Up
                }
            }
        }
        
        // Directyly up:
        if (gameBoard[fruitID].tileRow < gameBoard[headID].tileRow && gameBoard[fruitID].tileCol == gameBoard[headID].tileCol) {
            if gameBoard[headID].facing != .Down {
                newDirection = .Up
            } else {
                if arc4random_uniform(2) > 0 && !gameBoard[headID + boardCol].isWall {
                    newDirection = .Right
                } else {
                    newDirection = .Left
                }
            }
        }
        
        // Up left:
        if (gameBoard[fruitID].tileRow < gameBoard[headID].tileRow && gameBoard[fruitID].tileCol < gameBoard[headID].tileCol) {
            if gameBoard[headID].facing != .Up && gameBoard[headID].facing != .Left {
                if gameBoard[headID].facing == .Right && !gameBoard[headID - boardRow].isWall {
                    newDirection = .Up
                } else {
                    newDirection = .Left
                }
            }
        }
        
        // Directly left:
        if (gameBoard[fruitID].tileRow == gameBoard[headID].tileRow && gameBoard[fruitID].tileCol < gameBoard[headID].tileCol) {
            if gameBoard[headID].facing != .Right {
                newDirection = .Left
            } else {
                if arc4random_uniform(2) > 0 && !gameBoard[headID + boardRow].isWall {
                    newDirection = .Down
                } else {
                    newDirection = .Up
                }
            }
        }
        
        // Down left:
        if (gameBoard[fruitID].tileRow > gameBoard[headID].tileRow && gameBoard[fruitID].tileCol < gameBoard[headID].tileCol) {
            if gameBoard[headID].facing != .Left && gameBoard[headID].facing != .Down {
                if gameBoard[headID].facing == .Right {
                    newDirection = .Down
                } else {
                    newDirection = .Left
                }
            }
        }
    }
    
    
    func gameOver() {
        print("Game Over")
        gameTimer.invalidate()
    }
}
