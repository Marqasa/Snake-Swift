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
var shortestPath = Path()
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

//TODO: Create a tile type enum (first attempt ran into problems with comparing associated values)

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
        gameState.tailID = tailID
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
        if shortestPath.route.isEmpty || !shortestPath.findsFruit {
            Path.currentNumberSafePaths = 0
            shortestPath = Path()
            longestPath = []
            findPaths(centreTile: gameState.snake[0], Path(), state: gameState, lookahead: boardSize.rawValue * 2)
        }
        
        if !shortestPath.route.isEmpty {
            newDirection = shortestPath.route[0]
            shortestPath.route.remove(at: 0)
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
    
    //TODO: Add max lookahead to improve performance
    func findPaths(centreTile: Int, _ path: Path, state: GameState, lookahead: Int) {
        print("Safe paths found = \(Path.currentNumberSafePaths)")
        if shortestPath.moves > 0 {
//            print("Moves: \(shortestPath.moves)")
            if path.moves >= shortestPath.moves {
                return
            }
        }
        if path.route.count > lookahead {
            print("Lookahead reached:\n\(path.route)")
            shortestPath = path
        }
        if Path.currentNumberSafePaths >= Path.maxNumberSafePaths {
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
//                print("Tile not safe: \(tileID)")
                return false
            } else {
                return true
            }
        }
        
        func tileIsTail(_ tileID: Int) -> Bool {
            if state.board[tileID].isTail {
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
        
        // Check tile in direction:
        func checkTile(tileID: Int, direction: Direction) -> Bool {
            
            // If tile is safe:
            if tileIsSafe(tileID) {
                var tempState = state
                var tempPath = path
                tempPath.route.append(direction)
                tempPath.move()
                
                // Check for tail:
                if tileIsTail(tileID) {
                    tempPath.findsTail = true
                    if tempPath.findsFruit {
                        tempPath.findsFruitAndTail = true
                    }
                }
                
                // Check for fruit:
                if tileIsFruit(tileID) {
                    tempPath.findsFruit = true
                }
                
                // If path finds fruit and tail, update shortest path and return true:
                if tempPath.findsFruitAndTail {
                    shortestPath = tempPath
                    Path.currentNumberSafePaths += 1
                    return true
                }
                    //TODO: Optimize longestPath to improve performance
                else if tempPath.findsTail {
                    if tempPath.route.count > longestPath.count {
                        longestPath = tempPath.route
                    }
                }
                
                middleTile = tileID
                tempState.board[tempState.snake[0]].direction = direction
                tempState.update(live: false)
                findPaths(centreTile: middleTile, tempPath, state: tempState, lookahead: lookahead)
            }
            return false
        }
        
        allDirections: for direction in sortedDirections {

            switch direction {
            case .Up:
                if checkTile(tileID: upTile, direction: .Up) { break allDirections }
            case .Right:
                if checkTile(tileID: rightTile, direction: .Right) { break allDirections }
            case .Down:
                if checkTile(tileID: downTile, direction: .Down) { break allDirections }
            case .Left:
                if checkTile(tileID: leftTile, direction: .Left) { break allDirections }
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
