//
//  ViewController.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 26/09/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

let GAMESPEED = 0.1

//TODO: Are all these Globals necessary?
var boardCol = 0, boardRow = 0
var fruitHue: CGFloat = 0, snakeHue: CGFloat = 0
var shortestPath = Path()

class ViewController: UIViewController {
    let boardSize = BoardSize.medium
    var gameTimer = Timer()
    var tileSize: CGFloat = 0.0, yPos: CGFloat = 0.0
    var newDirection: Direction = .right
    var isPaused = false
    var upSafe = false, rightSafe = false, downSafe = false, leftSafe = false
    var path = [Direction]()
    var gameState = GameState()
    var gameView: GameView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardCol = Int(sqrt(Double(boardSize.rawValue)))
        boardRow = 1
        tileSize = self.view.bounds.size.width / CGFloat(boardCol)
        yPos = self.view.bounds.height / 5
        newGame()
    }
    
    func newGame() {
        gameView = GameView(size: boardCol)
        
        // Fill the gameBoard with BoardTiles:
        for x in 0..<boardCol {
            for y in 0..<boardCol {
                var tile = Tile()
                tile.col = x
                tile.row = y
                
                // Check if the tile is a wall
                if y == 0 || x == 0 || x == boardCol - 1 || y == boardCol - 1 {
                    tile.type = .wall(UIColor.black)
                }
                
                gameState.board.append(tile)
                
                let tileView = TileView(frame: CGRect(x: CGFloat(x) * tileSize, y: (CGFloat(y) * tileSize) + yPos, width: tileSize, height: tileSize))
                tileView.tile = tile
                
                // Accessing Subscripts Through Optional Chaining
                gameView?[x, y] = tileView
                
                self.view.addSubview(tileView)
            }
        }
        
        // Add the snake:
        let headID = boardRow + (boardCol * 3)
        gameState.snake.append(headID)
        gameState[headID].type = .head(.right, UIColor.red)
        gameView?[headID].tile = gameState[headID]
        
        let bodyID = headID - boardCol
        gameState.snake.append(bodyID)
        gameState[bodyID].type = .body(.right, .rightLeft, UIColor.red)
        gameView?[bodyID].tile = gameState[bodyID]
        
        let tailID = bodyID - boardCol
        gameState.snake.append(tailID)
        gameState[tailID].type = .tail(.right, UIColor.red)
        gameView?[tailID].tile = gameState[tailID]
        
        // Add a new fruit
        gameState.newFruit()
        if let fruitID = gameState.fruitID {
            gameView?[fruitID].tile = gameState[fruitID]
        }
        
        // Start the game
        gameTimer = Timer.scheduledTimer(withTimeInterval: GAMESPEED, repeats: true) { timer in
            self.gameLoop()
        }
    }
    
    // The game loop:
    func gameLoop() {
        if shortestPath.route.isEmpty || !shortestPath.findsTail {
            Path.currentNumberSafePaths = 0
            shortestPath = Path()
            findPaths(centreTile: gameState.snake[0], Path(), state: gameState, lookahead: 0)
        }
        
        newDirection = shortestPath.route[0]
        shortestPath.route.remove(at: 0)
        shortestPath.moves -= 1
        
        
        gameState.head = .head(newDirection, gameState.head.color()!)
        gameState.update(live: true)
        if gameState.gameOver {
            gameOver()
        }
        
        updateGameView()
    }
    
    func updateGameView() {
        for i in gameState.needsDisplay {
            gameView?[i].tile = gameState.board[i]
            gameView?[i].setNeedsDisplay()
            gameState.needsDisplay.remove(i)
        }
    }
    
    /*
     TODO: Refine findPaths so that each direction is checked at the current depth before searching any deeper.
     Goal being to avoid deep searches in one direction when the shortest path can be found much quicker from another.
     Array of paths to check. Paths are only checked if their moves property <= current depth value.
     Array is cycled at beginning of each depth increment.
     Paths carry with them a centre tile and an associated gameState.
     Once a path finds the fruit. All other paths are suspended and search for the tail begins.
     Non fruit findind paths are only resumed if all fruit finding paths are proven to be unsafe.
     New paths are added to the array as they are found.
     Once the shortest path is found, the search ends.
     */
    func findPaths(centreTile: Int, _ path: Path, state: GameState, lookahead: Int) {
        if shortestPath.route.isEmpty && !path.route.isEmpty {
            shortestPath = path
        }
        if lookahead >= 50 {
            if !shortestPath.findsTail && path.findsTail {
                shortestPath = path
            }
            return
        }
        
        
        // End search if shortestPath is already optimal or if current path is longer than shortestPath
        if shortestPath.findsFruitAndTail {
            //            if shortestPath.moves < gameState.fruitDistance || path.moves >= shortestPath.moves {
            //                return
            //            }
            return
        }
        if gameState.fruitID == 0 && path.findsTail {
            shortestPath = path
            return
        }
        //        if path.route.count > lookahead {
        //            shortestPath = path
        //            return
        //        }
        //        if debugCounter > 1000 {
        //            if shortestPath.route.isEmpty && path.findsTail {
        //                shortestPath = path
        //                return
        //            } else if !shortestPath.route.isEmpty {
        //                return
        //            }
        //        }
        
        var middleTile = centreTile
        var upTile = 0, rightTile = 0, downTile = 0, leftTile = 0
        
        func setAdjacentTileIDs(_ tileID: Int) {
            upTile = tileInDirection(tileID, .up)
            rightTile = tileInDirection(tileID, .right)
            downTile = tileInDirection(tileID, .down)
            leftTile = tileInDirection(tileID, .left)
        }
        
        setAdjacentTileIDs(centreTile)
        
        // Sort directions to optimize searching:
        let sortedDirections = Direction.allCases.sorted {
            if !path.findsFruit {
                switch ($0, $1) {
                case (.right, .up):
                    if state.fruitIsToTheRight || state.fruitIsBelow {
                        return true
                    } else {
                        return false
                    }
                case (.down, .right):
                    if state.fruitIsBelow || state.fruitIsToTheLeft {
                        return true
                    } else {
                        return false
                    }
                case (.left, .down):
                    if state.fruitIsToTheLeft || state.fruitIsAbove {
                        return true
                    } else {
                        return false
                    }
                case (.left, .up):
                    if state.fruitIsToTheLeft || state.fruitIsBelow {
                        return true
                    } else {
                        return false
                    }
                case (.down, .up):
                    return state.fruitIsBelow
                case (.left, .right):
                    return state.fruitIsToTheLeft
                default:
                    return false
                }
            } else {
                switch ($0, $1) {
                case (.right, .up):
                    if state.tailIsToTheRight || state.tailIsBelow {
                        return true
                    } else {
                        return false
                    }
                case (.down, .right):
                    if state.tailIsBelow || state.tailIsToTheLeft {
                        return true
                    } else {
                        return false
                    }
                case (.left, .down):
                    if state.tailIsToTheLeft || state.tailIsAbove {
                        return true
                    } else {
                        return false
                    }
                case (.left, .up):
                    if state.tailIsToTheLeft || state.tailIsBelow {
                        return true
                    } else {
                        return false
                    }
                case (.down, .up):
                    return state.tailIsBelow
                case (.left, .right):
                    return state.tailIsToTheLeft
                default:
                    return false
                }
            }
        }
        
        // Check tile in direction:
        func checkTile(tileID: Int, direction: Direction) -> Bool {
            var tempState = state
            var tempPath = path
            var depth = lookahead
            
            // Check tile type:
            switch state.board[tileID].type {
            case .wall, .body:
                return false
            case .tail(_):
                tempPath.findsTail = true
                if tempPath.findsFruit {
                    tempPath.findsFruitAndTail = true
                }
            case .fruit:
                tempPath.findsFruit = true
            default:
                break
            }
            
            tempPath.route.append(direction)
            tempPath.move()
            
            // If path finds fruit and tail, update shortest path and return true:
            if tempPath.findsFruitAndTail {
                shortestPath = tempPath
                Path.currentNumberSafePaths += 1
                return true
            }
            
            middleTile = tileID
            tempState.head = .head(direction, tempState.head.color()!)
            tempState.update(live: false)
            depth += 1
            findPaths(centreTile: middleTile, tempPath, state: tempState, lookahead: depth)
            
            return false
        }
        
        allDirections: for direction in sortedDirections {
            
            switch direction {
            case .up:
                if checkTile(tileID: upTile, direction: .up) { break allDirections }
            case .right:
                if checkTile(tileID: rightTile, direction: .right) { break allDirections }
            case .down:
                if checkTile(tileID: downTile, direction: .down) { break allDirections }
            case .left:
                if checkTile(tileID: leftTile, direction: .left) { break allDirections }
            }
        }
    }
    
    func tileInDirection(_ tileID: Int, _ direction: Direction) -> Int {
        switch direction {
        case .up:
            return tileID - boardRow
        case .right:
            return tileID + boardCol
        case .down:
            return tileID + boardRow
        case .left:
            return tileID - boardCol
        }
    }
    
    func gameOver() {
        print("Game Over")
        gameTimer.invalidate()
    }
}
