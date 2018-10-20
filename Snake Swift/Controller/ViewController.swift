//
//  ViewController.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 26/09/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

// Global enumeration
enum Direction: CaseIterable {
    case up
    case upRight
    case right
    case downRight
    case down
    case downLeft
    case left
    case upLeft
}

class ViewController: UIViewController {
    var gameTimer = Timer()
    var newDirection: Direction = .right
    var gameSettings = GameSettings()
    var snakeLogic = SnakeLogic()
    var gameState: GameState?
    var gameView: GameView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newGame()
    }
    
    func newGame() {
        gameState = GameState(size: gameSettings.boardSize.rawValue)
        gameView = GameView(size: gameSettings.boardSize.rawValue, bounds: self.view.bounds)
        
        // Fill the board with tiles:
        for x in 0..<gameState!.col {
            for y in 0..<gameState!.col {
                
                // Make a new tile and add it the the board:
                let tile = gameState!.makeTile(x, y)
                
                // Make a new tileView and add it as a subview:
                self.view.addSubview(gameView!.makeTileView(x, y, tile))
            }
        }
        
        // Add the snake:
        let headID = (gameState!.col * 3) + gameState!.row
        gameState!.snake.append(headID)
        gameState![headID]!.kind = .head(.right, UIColor.red)
        gameView![headID]!.tile = gameState![headID]!
        
        let bodyID = headID - gameState!.col
        gameState!.snake.append(bodyID)
        gameState![bodyID]!.kind = .body(.right, .rightLeft, UIColor.red)
        gameView![bodyID]!.tile = gameState![bodyID]!
        
        let tailID = bodyID - gameState!.col
        gameState!.snake.append(tailID)
        gameState![tailID]!.kind = .tail(.right, UIColor.red)
        gameView![tailID]!.tile = gameState![tailID]!
        
        // Add a new fruit
        gameState!.newFruit()
        if let fruitID = gameState!.fruitID {
            gameView![fruitID]!.tile = gameState![fruitID]!
        }
        
        // Start the game
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameSettings.speed, repeats: true) { timer in
            self.gameLoop()
        }
    }
    
    // The game loop:
    func gameLoop() {
        newDirection = snakeLogic.getNewDirection(state: gameState!)
        
        gameState!.headKind = .head(newDirection, gameState!.headKind.color()!)
        
        let result = gameState!.update(live: true)
        switch result {
        case .newFruit: snakeLogic.shortestPath = nil
        case .gameOver: gameOver()
        case .victory: victory()
        default: break
        }

        
        updateGameView()
    }
    
    func updateGameView() {
        for i in gameState!.needsDisplay {
            gameView?[i]?.tile = gameState!.board[i]
            gameView?[i]?.setNeedsDisplay()
            gameState!.needsDisplay.remove(i)
        }
    }
    
    func gameOver() {
        print("Game Over!")
        gameTimer.invalidate()
    }
    
    func victory() {
        print("Victory!")
        gameState!.restart()
    }
}
