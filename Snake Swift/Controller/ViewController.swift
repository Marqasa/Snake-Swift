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
var shortestPath = [Direction]()

enum Direction: CaseIterable {
    case Up
    case Right
    case Down
    case Left
}

enum BoardSize: Int {
    case Tiny = 25
    case Small = 36
    case Medium = 64
    case Large = 100
}

enum BodyShape {
    case UpRight
    case UpDown
    case UpLeft
    case RightDown
    case RightLeft
    case DownLeft
}

class ViewController: UIViewController {
    let boardSize = BoardSize.Medium
    var longestPath = [Direction]()
    var gameTimer = Timer()
    var tileSize: CGFloat = 0.0, yPos: CGFloat = 0.0
    var newDirection: Direction = .Right
    var fruitID = 0, moves = 0, routeID = 0
    var isPaused = false
    var upSafe = false, rightSafe = false, downSafe = false, leftSafe = false
    var gameView = [TileView]()
    var path = [Direction]()
    var gameState = GameState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardCol = Int(sqrt(Double(boardSize.rawValue)))
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
                var tile = Tile()
                let tileView = TileView(frame: CGRect(x: CGFloat(x) * tileSize, y: (CGFloat(y) * tileSize) + yPos, width: tileSize, height: tileSize))
                
                // Set the BoardTile type:
                if y == 0 || x == 0 || x == boardCol - 1 || y == boardCol - 1 {
                    tile.isWall = true
                }
                
                tileView.tile = tile
                gameState.board.append(tile)
                gameView.append(tileView)
                self.view.addSubview(tileView)
                i += 1
            }
        }
        
        // Add the snake:
        let headID = boardRow + (boardCol * 3)
        gameState.board[headID].isHead = true
        gameState.board[headID].direction = .Right
        gameState.snake.append(headID)
        gameView[headID].tile = gameState.board[headID]
        
        let bodyID = headID - boardCol
        gameState.board[bodyID].isBody = true
        gameState.board[bodyID].direction = .Right
        gameState.board[bodyID].bodyShape = .RightLeft
        gameState.snake.append(bodyID)
        gameView[bodyID].tile = gameState.board[bodyID]
        
        let tailID = headID - (boardCol * 2)
        gameState.board[tailID].isTail = true
        gameState.board[tailID].direction = .Right
        gameState.snake.append(tailID)
        gameView[tailID].tile = gameState.board[tailID]
        
        // Add a new fruit
        let fruitID = gameState.newFruit()
        gameView[fruitID].tile = gameState.board[fruitID]
        
        // Start the game
        gameTimer = Timer.scheduledTimer(withTimeInterval: GAMESPEED, repeats: true) { timer in
            self.gameLoop()
        }
    }
        
    // The game loop:
    func gameLoop() {
        if shortestPath.isEmpty {
            longestPath = []
            findPaths(centreTile: gameState.snake[0], Path(), state: gameState)
        }
        
        if !shortestPath.isEmpty {
            newDirection = shortestPath[0]
            shortestPath.remove(at: 0)
        } else if !longestPath.isEmpty {
            newDirection = longestPath[0]
            longestPath.remove(at: 0)
        }
        
        gameState.board[gameState.snake[0]].direction = newDirection
        gameState.update(live: true)
        
        for i in gameState.needsDisplay {
            gameView[i].tile = gameState.board[i]
            gameView[i].setNeedsDisplay()
            gameState.needsDisplay.remove(i)
        }
    }
    
    func findPaths(centreTile: Int, _ path: Path, state: GameState) {
        
        if !shortestPath.isEmpty && path.route.count > shortestPath.count {
            return
        }
        
        var middleTile = centreTile
        var upTile = 0, rightTile = 0, downTile = 0, leftTile = 0
        
        func setAdjacentTileIDs(_ tileID: Int) {
            upTile = tileInDirection(tileID, .Up)
            rightTile = tileInDirection(tileID, .Right)
            downTile = tileInDirection(tileID, .Down)
            leftTile = tileInDirection(tileID, .Left)
        }
        
        func tileIsSafe(_ tileID: Int) -> Bool {
            if state.board[tileID].isWall || state.board[tileID].isBody {
                return false
            } else {
                return true
            }
        }
        
        func tileIsTail(_ tileID: Int) -> Bool {
            if state.board[tileID].isTail || state.board[tileID].wasTail {
                return true
            } else {
                return false
            }
        }
        
        func tileIsFruit(_ tileID: Int) -> Bool {
            if state.board[tileID].isFruit {
                return true
            } else {
                return false
            }
        }
        
        setAdjacentTileIDs(centreTile)
        
        //TODO: Sort directions to search most likely paths first (based on fruit location)
        allDirections: for direction in Direction.allCases {
            switch direction {
            case .Up:
                if tileIsSafe(upTile) {
                    var tempState = state
                    var pathUp = path
                    
                    if tileIsTail(upTile) {
                        pathUp.findsTail = true
                    }
                    
                    if tileIsFruit(upTile) {
                        pathUp.findsFruit = true
                    }
                    
                    pathUp.route.append(.Up)
                    
                    if pathUp.findsFruit && pathUp.findsTail {
                        if !shortestPath.isEmpty {
                            if pathUp.route.count < shortestPath.count {
                                shortestPath = pathUp.route
                            }
                        } else {
                            shortestPath = pathUp.route
                        }
                        break allDirections
                    } else if pathUp.findsTail {
                        if pathUp.route.count > longestPath.count {
                            longestPath = pathUp.route
                        }
                        continue allDirections
                    }
                    
                    middleTile = upTile
                    tempState.board[tempState.snake[0]].direction = .Up
                    if let tail = tempState.snake.last {
                        tempState.board[tail].wasTail = true
                    }
                    tempState.update(live: false)
                    findPaths(centreTile: middleTile, pathUp, state: tempState)
                }
            case .Right:
                if tileIsSafe(rightTile) {
                    var tempState = state
                    var pathRight = path
                    
                    if tileIsTail(rightTile) {
                        pathRight.findsTail = true
                    }
                    
                    if tileIsFruit(rightTile) {
                        pathRight.findsFruit = true
                    }
                    
                    pathRight.route.append(.Right)
                    
                    if pathRight.findsFruit && pathRight.findsTail {
                        if !shortestPath.isEmpty {
                            if pathRight.route.count < shortestPath.count {
                                shortestPath = pathRight.route
                            }
                        } else {
                            shortestPath = pathRight.route
                        }
                        break allDirections
                    } else if pathRight.findsTail {
                        if pathRight.route.count > longestPath.count {
                            longestPath = pathRight.route
                        }
                        continue allDirections
                    }
                    
                    middleTile = rightTile
                    tempState.board[tempState.snake[0]].direction = .Right
                    if let tail = tempState.snake.last {
                        tempState.board[tail].wasTail = true
                    }
                    tempState.update(live: false)
                    findPaths(centreTile: rightTile, pathRight, state: tempState)
                }
            case .Down:
                if tileIsSafe(downTile) {
                    var tempState = state
                    var pathDown = path
                    
                    if tileIsTail(downTile) {
                        pathDown.findsTail = true
                    }
                    
                    if tileIsFruit(downTile) {
                        pathDown.findsFruit = true
                    }
                    
                    pathDown.route.append(.Down)
                    
                    if pathDown.findsFruit && pathDown.findsTail {
                        if !shortestPath.isEmpty {
                            if pathDown.route.count < shortestPath.count {
                                shortestPath = pathDown.route
                            }
                        } else {
                            shortestPath = pathDown.route
                        }
                        break allDirections
                    } else if pathDown.findsTail {
                        if pathDown.route.count > longestPath.count {
                            longestPath = pathDown.route
                        }
                        continue allDirections
                    }
                    
                    middleTile = downTile
                    tempState.board[tempState.snake[0]].direction = .Down
                    if let tail = tempState.snake.last {
                        tempState.board[tail].wasTail = true
                    }
                    tempState.update(live: false)
                    findPaths(centreTile: downTile, pathDown, state: tempState)
                }
            case .Left:
                if tileIsSafe(leftTile) {
                    var tempState = state
                    var pathLeft = path
                    
                    if tileIsTail(leftTile) {
                        pathLeft.findsTail = true
                    }
                    
                    if tileIsFruit(leftTile) {
                        pathLeft.findsFruit = true
                    }
                    
                    pathLeft.route.append(.Left)
                    
                    if pathLeft.findsFruit && pathLeft.findsTail {
                        if !shortestPath.isEmpty {
                            if pathLeft.route.count < shortestPath.count {
                                shortestPath = pathLeft.route
                            }
                        } else {
                            shortestPath = pathLeft.route
                        }
                        break allDirections
                    } else if pathLeft.findsTail {
                        if pathLeft.route.count > longestPath.count {
                            longestPath = pathLeft.route
                        }
                        continue allDirections
                    }
                    
                    middleTile = leftTile
                    tempState.board[tempState.snake[0]].direction = .Left
                    if let tail = tempState.snake.last {
                        tempState.board[tail].wasTail = true
                    }
                    tempState.update(live: false)
                    findPaths(centreTile: leftTile, pathLeft, state: tempState)
                }
            }
        }
    }
    
    func tileInDirection(_ tileID: Int, _ direction: Direction) -> Int {
        switch direction {
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
    
    func gameOver() {
        print("Game Over")
        gameTimer.invalidate()
    }
}
