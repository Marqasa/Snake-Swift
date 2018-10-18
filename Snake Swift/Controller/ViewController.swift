//
//  ViewController.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 26/09/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

//TODO: Move globals into GameSettings structure
let GAMESPEED = 0.1
var boardCol = 0, boardRow = 0
var shortestPath = Path()

class ViewController: UIViewController {
    let boardSize = BoardSize.small
    var gameTimer = Timer()
    var tileSize: CGFloat = 0.0, yPos: CGFloat = 0.0
    var newDirection: Direction = .right
    var gameState = GameState()
    var gameView: GameView?
    var snakeLogic = SnakeLogic()
    
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
                    tile.kind = .wall(UIColor.black)
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
        // Optional Chaining and Forced Unwrapping
        gameState[headID]?.kind = .head(.right, UIColor.red)
        gameView?[headID]?.tile = gameState[headID]!
        
        let bodyID = headID - boardCol
        gameState.snake.append(bodyID)
        gameState[bodyID]?.kind = .body(.right, .rightLeft, UIColor.red)
        gameView?[bodyID]?.tile = gameState[bodyID]!
        
        let tailID = bodyID - boardCol
        gameState.snake.append(tailID)
        gameState[tailID]?.kind = .tail(.right, UIColor.red)
        gameView?[tailID]?.tile = gameState[tailID]!
        
        // Add a new fruit
        gameState.newFruit()
        if let fruitID = gameState.fruitID {
            gameView?[fruitID]?.tile = gameState[fruitID]!
        }
        
        // Start the game
        gameTimer = Timer.scheduledTimer(withTimeInterval: GAMESPEED, repeats: true) { timer in
            self.gameLoop()
        }
    }
    
    // The game loop:
    func gameLoop() {
//        snakeLogic.sortDirections(state: gameState)
//        newDirection = snakeLogic.sortedDirections[0]
        
        if shortestPath.route.isEmpty || !shortestPath.findsTail {
            shortestPath = Path()
            var fruitSearch = [Path.init(route: [], state: gameState, findsFruit: false, findsTail: false)]
            var tailSearch = [Path]()
            findPath(&fruitSearch, &tailSearch)
        }
        
        newDirection = shortestPath.route[0]
        shortestPath.route.remove(at: 0)
        
        gameState.head = .head(newDirection, gameState.head.color()!)
        gameState.update(live: true)
        if gameState.gameOver {
            gameOver()
        }
        
        updateGameView()
    }
    
    func updateGameView() {
        for i in gameState.needsDisplay {
            gameView?[i]?.tile = gameState.board[i]
            gameView?[i]?.setNeedsDisplay()
            gameState.needsDisplay.remove(i)
        }
    }
    
    // Search for the fastest safe path to the fruit:
    func findPath(_ fruitSearch: inout [Path], _ tailSearch: inout [Path]) {
        
        // Cap the number of possible paths considered. Once the cap is reach the path closest to the fruit/tail is chosen:
        if tailSearch.count > 100 {
            print("Tail search count: \(tailSearch.count)")
            shortestPath = tailSearch[0]
            return
        } else if fruitSearch.count > 100 {
            print("Fruit search count: \(fruitSearch.count)")
            shortestPath = fruitSearch[0]
            return
        }
        
        // Check tile in direction:
        func searchPath(_ path: Path, direction: Direction) {
            var newPath = path
            var tileID = 0
            
            switch direction {
            case .up:
                tileID = path.up
            case .right:
                tileID = path.right
            case .down:
                tileID = path.down
            case .left:
                tileID = path.left
            }
            
            // Check tile type:
            switch path.state[tileID]?.kind {
            case .wall?, .body?:
                return
            case .fruit?:
                newPath.findsFruit = true
            case .tail?:
                if newPath.findsFruit { newPath.findsTail = true }
            default:
                break
            }
            
            newPath.route.append(direction)
            newPath.state.head = .head(direction, UIColor.red)
            newPath.state.update(live: false)
            
            if newPath.findsFruit {
                tailSearch.append(newPath)
            } else {
                fruitSearch.append(newPath)
            }
        }
        
        if !tailSearch.isEmpty {
            let shortest = tailSearch[0].state.tailDistance
            var last = 0
            for (i, path) in tailSearch.enumerated() where path.state.tailDistance == shortest {
                if path.findsTail {
                    shortestPath = path
                    return
                }
                searchPath(path, direction: .up)
                searchPath(path, direction: .right)
                searchPath(path, direction: .down)
                searchPath(path, direction: .left)
                last = i
            }
            tailSearch.removeSubrange(0...last)
            
        } else if !fruitSearch.isEmpty {
            let shortest = fruitSearch[0].state.fruitDistance
            var last = 0
            for (i, path) in fruitSearch.enumerated() where path.state.fruitDistance == shortest {
                if path.depth > boardSize.rawValue * 2 {
                    print("Path depth: \(path.depth)")
                    shortestPath = path
                    return
                }
                searchPath(path, direction: .up)
                searchPath(path, direction: .right)
                searchPath(path, direction: .down)
                searchPath(path, direction: .left)
                last = i
            }
            fruitSearch.removeSubrange(0...last)
        } else {
            //TODO: No safe paths found. Game Over imminent:
            shortestPath.route.append(.up)
            return
        }
        fruitSearch.sort{ $0.state.fruitDistance < $1.state.fruitDistance }
        tailSearch.sort { $0.state.tailDistance < $1.state.tailDistance }
        findPath(&fruitSearch, &tailSearch)
    }
    
    func gameOver() {
        print("Game Over")
        gameTimer.invalidate()
    }
}
