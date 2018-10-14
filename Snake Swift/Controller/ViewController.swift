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
    let boardSize = BoardSize.large
    var gameTimer = Timer()
    var tileSize: CGFloat = 0.0, yPos: CGFloat = 0.0
    var newDirection: Direction = .right
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
        if shortestPath.route.isEmpty || !shortestPath.findsTail {
            shortestPath = Path()
            var newPath = Path()
            newPath.state = gameState
            findPath([newPath], [])
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
    func findPath(_ fruitSearch: [Path], _ tailSearch: [Path]) {
        
        // Cap the number of possible paths considered. Once the cap is reach the path closest to the fruit/tail is chosen:
        if tailSearch.count > 250 {
            shortestPath = tailSearch.sorted(by: {$0.state.tailDistance < $1.state.tailDistance })[0]
            return
        } else if fruitSearch.count > 250 {
            shortestPath = fruitSearch.sorted(by: {$0.state.fruitDistance < $1.state.fruitDistance })[0]
            return
        }
        
        var newFruitSearch = [Path]()
        var newTailSearch = [Path]()
        
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
                newTailSearch.append(newPath)
            } else {
                newFruitSearch.append(newPath)
            }
        }
        
        if !tailSearch.isEmpty {
            for path in tailSearch {
                if path.findsTail {
                    shortestPath = path
                    return
                }
                searchPath(path, direction: .up)
                searchPath(path, direction: .right)
                searchPath(path, direction: .down)
                searchPath(path, direction: .left)
            }
            // Keep track of fruitSearch paths in case all tailSearch paths are proven to be unsafe:
            newFruitSearch = fruitSearch
            
        } else if !fruitSearch.isEmpty {
            for path in fruitSearch {
                if path.depth > 50 {
                    shortestPath = path
                    return
                }
                searchPath(path, direction: .up)
                searchPath(path, direction: .right)
                searchPath(path, direction: .down)
                searchPath(path, direction: .left)
            }
        } else {
            return
        }
        findPath(newFruitSearch, newTailSearch)
    }
    
    func gameOver() {
        print("Game Over")
        gameTimer.invalidate()
    }
}
