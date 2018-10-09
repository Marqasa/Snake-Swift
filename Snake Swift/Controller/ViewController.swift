//
//  ViewController.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 26/09/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

let GAMESPEED = 0.2

//TODO: Are all these Globals necessary?
var boardCol = 0, boardRow = 0
var fruitHue: CGFloat = 0, snakeHue: CGFloat = 0
var shortestPath = [Direction]()
//{
//    didSet {
//        print("New shortest path found:\n \(shortestPath)")
//    }
//}

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
enum TileType: Equatable {
    case Wall
    case Head(Direction)
    case Body(Direction, BodyShape)
    case Tail(Direction)
    case Fruit
    case Empty
    indirect case Dual(TileType, TileType)
}

//TODO: Create a tile type enum

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
        for x in 0..<boardCol {
            for y in 0..<boardCol {
                var tile = Tile()
                tile.col = x
                tile.row = y
                
                // Check if the tile is a wall
                if y == 0 || x == 0 || x == boardCol - 1 || y == boardCol - 1 {
                    tile.type = .Wall
                    tile.isWall = true
                }
                
                gameState.board.append(tile)
                
                let tileView = TileView(frame: CGRect(x: CGFloat(x) * tileSize, y: (CGFloat(y) * tileSize) + yPos, width: tileSize, height: tileSize))
                tileView.tile = tile
                gameView.append(tileView)
                self.view.addSubview(tileView)
            }
        }
        
        // Add the snake:
        let headID = boardRow + (boardCol * 3)
        gameState.headID = headID
        gameState.board[headID].isHead = true
        gameState.board[headID].type = .Head(.Right)
        gameState.board[headID].direction = .Right
        gameState.snake.append(headID)
        gameView[headID].tile = gameState.board[headID]
        
        let bodyID = headID - boardCol
        gameState.board[bodyID].isBody = true
        gameState.board[bodyID].type = .Body(.Right, .RightLeft)
        gameState.board[bodyID].direction = .Right
        gameState.board[bodyID].bodyShape = .RightLeft
        gameState.snake.append(bodyID)
        gameView[bodyID].tile = gameState.board[bodyID]
        
        let tailID = headID - (boardCol * 2)
        gameState.tailID = tailID
        gameState.board[tailID].isTail = true
        gameState.board[tailID].type = .Tail(.Right)
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
        
        updateGameView()
    }
    
    func updateGameView() {
        for i in gameState.needsDisplay {
            gameView[i].tile = gameState.board[i]
            gameView[i].setNeedsDisplay()
            gameState.needsDisplay.remove(i)
        }
    }
    
    func findPaths(centreTile: Int, _ path: Path, state: GameState) {
        if !shortestPath.isEmpty {
            if path.route.count > shortestPath.count {
                return
            }
        }
//        print("Snake position is: \(state.snake)")
        if path.route.count > (state.snake.count * 2) {
//            print("Path too long")
            return
        }
//        if !shortestPath.isEmpty {
//            return
//        }
//        print("Searching for path from tile \(centreTile)")
        
//        if !shortestPath.isEmpty && path.route.count > shortestPath.count {
//            return
//        }
        
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
//                print("Tile not safe: \(tileID)")
                return false
            } else {
                return true
            }
        }
        
        func tileIsTail(_ tileID: Int) -> Bool {
            if state.board[tileID].isTail || (state.board[tileID].wasTail && !state.board[tileID].isBody) {
                return true
            } else {
                return false
            }
//            if state.board[tileID].isTail || state.board[tileID].wasTail {
//                return true
//            } else {
//                return false
//            }
        }
        
        func tileIsFruit(_ tileID: Int) -> Bool {
            if state.board[tileID].isFruit {
                return true
            } else {
                return false
            }
        }
        
        setAdjacentTileIDs(centreTile)
        
        // Sort directions to optimize searching:
        let sortedDirections = Direction.allCases.sorted {
            if !path.findsFruit {
                switch ($0, $1) {
                case (.Right, .Up):
                    if state.fruitIsToTheRight || state.fruitIsBelow {
                        return true
                    } else {
                        return false
                    }
                case (.Down, .Right):
                    if state.fruitIsBelow || state.fruitIsToTheLeft {
                        return true
                    } else {
                        return false
                    }
                case (.Left, .Down):
                    if state.fruitIsToTheLeft || state.fruitIsAbove {
                        return true
                    } else {
                        return false
                    }
                case (.Left, .Up):
                    if state.fruitIsToTheLeft || state.fruitIsBelow {
                        return true
                    } else {
                        return false
                    }
                case (.Down, .Up):
                    return state.fruitIsBelow
                case (.Left, .Right):
                    return state.fruitIsToTheLeft
                default:
                    return false
                }
            } else {
                switch ($0, $1) {
                case (.Right, .Up):
                    if state.tailIsToTheRight || state.tailIsBelow {
                        return true
                    } else {
                        return false
                    }
                case (.Down, .Right):
                    if state.tailIsBelow || state.tailIsToTheLeft {
                        return true
                    } else {
                        return false
                    }
                case (.Left, .Down):
                    if state.tailIsToTheLeft || state.tailIsAbove {
                        return true
                    } else {
                        return false
                    }
                case (.Left, .Up):
                    if state.tailIsToTheLeft || state.tailIsBelow {
                        return true
                    } else {
                        return false
                    }
                case (.Down, .Up):
                    return state.tailIsBelow
                case (.Left, .Right):
                    return state.tailIsToTheLeft
                default:
                    return false
                }
            }
        }
        
        allDirections: for direction in sortedDirections {
//            if !shortestPath.isEmpty {
//                return
//            }
            switch direction {
            case .Up:
                if tileIsSafe(upTile) {
                    var tempState = state
                    var pathUp = path
                    
                    if tileIsTail(upTile) {
                        pathUp.findsTail = true
                        if path.findsFruit {
//                            print("Path found tail at \(upTile)")
                            pathUp.findsFruitAndTail = true
                        }
                    }
                    
                    if tileIsFruit(upTile) {
//                        print("Path found fruit at \(upTile)")
                        pathUp.findsFruit = true
//                        tempState.allFruit()
                    }
                    
                    pathUp.route.append(.Up)
                    
                    if pathUp.findsFruitAndTail {
                        if !shortestPath.isEmpty {
                            if pathUp.route.count < shortestPath.count {
                                shortestPath = pathUp.route
                            }
                        } else {
                            shortestPath = pathUp.route
                        }
                        break allDirections
                        
                        //TODO: Path currently isn't marked as finding the tail until after the fruit is found
                    } else if pathUp.findsTail {
                        if pathUp.route.count > longestPath.count {
                            longestPath = pathUp.route
                        }
//                        continue allDirections
                    }
                    
                    middleTile = upTile
                    tempState.board[tempState.snake[0]].direction = .Up
//                    if let tail = tempState.snake.last {
//                        tempState.board[tail].wasTail = true
//                    }
                    tempState.update(live: false)
                    findPaths(centreTile: middleTile, pathUp, state: tempState)
                }
            case .Right:
                if tileIsSafe(rightTile) {
                    var tempState = state
                    var pathRight = path
                    
                    if tileIsTail(rightTile) {
                        pathRight.findsTail = true
                        if path.findsFruit {
//                            print("Path found tail at \(rightTile)")
                            pathRight.findsFruitAndTail = true
                        }
                    }
                    
                    if tileIsFruit(rightTile) {
//                        print("Path found fruit at \(rightTile)")
                        pathRight.findsFruit = true
//                        tempState.allFruit()
                    }
                    
                    pathRight.route.append(.Right)
                    
                    if pathRight.findsFruitAndTail {
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
//                        continue allDirections
                    }
                    
                    middleTile = rightTile
                    tempState.board[tempState.snake[0]].direction = .Right
//                    if let tail = tempState.snake.last {
//                        tempState.board[tail].wasTail = true
//                    }
                    tempState.update(live: false)
                    findPaths(centreTile: rightTile, pathRight, state: tempState)
                }
            case .Down:
                if tileIsSafe(downTile) {
                    var tempState = state
                    var pathDown = path
                    
                    if tileIsTail(downTile) {
                        pathDown.findsTail = true
                        if path.findsFruit {
//                            print("Path found tail at \(downTile)")
                            pathDown.findsFruitAndTail = true
                        }
                    }
                    
                    if tileIsFruit(downTile) {
//                        print("Path found fruit at \(downTile)")
                        pathDown.findsFruit = true
//                        tempState.allFruit()
                    }
                    
                    pathDown.route.append(.Down)
                    
                    if pathDown.findsFruitAndTail {
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
//                        continue allDirections
                    }
                    
                    middleTile = downTile
                    tempState.board[tempState.snake[0]].direction = .Down
//                    if let tail = tempState.snake.last {
//                        tempState.board[tail].wasTail = true
//                    }
                    tempState.update(live: false)
                    findPaths(centreTile: downTile, pathDown, state: tempState)
                }
            case .Left:
                if tileIsSafe(leftTile) {
                    var tempState = state
                    var pathLeft = path
                    
                    if tileIsTail(leftTile) {
                        pathLeft.findsTail = true
                        if path.findsFruit {
//                            print("Path found tail at \(leftTile)")
                            pathLeft.findsFruitAndTail = true
                        }
                    }
                    
                    if tileIsFruit(leftTile) {
//                        print("Path found fruit at \(leftTile)")
                        pathLeft.findsFruit = true
//                        tempState.allFruit()
                    }
                    
                    pathLeft.route.append(.Left)
                    
                    if pathLeft.findsFruitAndTail {
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
//                        continue allDirections
                    }
                    
                    middleTile = leftTile
                    tempState.board[tempState.snake[0]].direction = .Left
//                    if let tail = tempState.snake.last {
//                        tempState.board[tail].wasTail = true
//                    }
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
