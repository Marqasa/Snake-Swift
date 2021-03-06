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
    var newDirection: Direction = .right
    var gameSettings = GameSettings()
    var snakeLogic = SnakeLogic()
    var gameState: GameState?
    var gameView: GameView?
    var controlView: ControlView!
    var gameTimer: Timer?
    var newGameRequested = false
    var gameRunning = false
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var watchButton: UIButton!
    
    // Set up the game in play mode
    @IBAction func playButtonPressed(_ sender: UIButton) {
        gameSettings.watchMode = false
        gameSettings.speed = 0.2
        if controlView == nil {
            let height = view.bounds.height - view.bounds.width - (view.bounds.height / 5)
            let y = view.bounds.width + (view.bounds.height / 5)
            controlView = ControlView(frame: CGRect(x: 0, y: y, width: view.bounds.width, height: height))
            view.addSubview(controlView)
        } else {
            controlView.isHidden = false
            controlView.route = []
        }
        playButton.isHidden = true
        watchButton.isHidden = true
        newGame()
    }
    
    // Set up the game in watch mode
    @IBAction func watchButtonPressed(_ sender: UIButton) {
        UIApplication.shared.isIdleTimerDisabled = true
        gameSettings.watchMode = true
        gameSettings.speed = 0.1
        if gameRunning {
            newGameRequested = true
        } else {
            newGame()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Initialize and start a new game
    func newGame() {
        endGame()
        snakeLogic.shortestPath = nil
        newGameRequested = false
        gameRunning = true
        gameState = GameState(size: gameSettings.boardSize.rawValue)
        gameView = GameView(bounds: view.bounds, state: gameState!)
        view.addSubview(gameView!)
        newDirection = gameState!.headDirection
        
        // Start the game
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameSettings.speed, repeats: true) { timer in
            self.gameLoop()
        }
    }
    
    // The game loop
    func gameLoop() {
        
        if gameSettings.watchMode {
            
            // AI chooses direction
            newDirection = snakeLogic.getNewDirection(state: gameState!)
        } else {
            
            // User chooses direction
            if !controlView.route.isEmpty {
                
                // Snake can't go backwards
                switch controlView.route[0] {
                case .up:       if gameState!.headDirection != .down    { newDirection = .up }
                case .right:    if gameState!.headDirection != .left    { newDirection = .right }
                case .down:     if gameState!.headDirection != .up      { newDirection = .down }
                case .left:     if gameState!.headDirection != .right   { newDirection = .left }
                default: break
                }
                controlView.route.remove(at: 0)
            }
        }
        gameState!.headDirection = newDirection
        
        // Update game and get result
        let result = gameState!.update()
        switch result {
        case .fruitEaten:
            gameState!.newFruit()
            snakeLogic.shortestPath = nil
        case .gameOver: gameOver()
        case .gameWon: victory()
        default: break
        }
        
        
        updateGameView()
        
        if newGameRequested {
            newGame()
        }
    }
    
    func updateGameView() {
        for i in gameState!.needsDisplay {
            gameView?[i]?.tile = gameState!.board[i]
            gameView?[i]?.setNeedsDisplay()
            gameState!.needsDisplay.remove(i)
        }
    }
    
    func gameOver() {
        UIApplication.shared.isIdleTimerDisabled = false
        gameRunning = false
        if controlView != nil { controlView.isHidden = true }
        playButton.isHidden = false
        watchButton.isHidden = false
        gameTimer?.invalidate()
    }
    
    func victory() {
        UIApplication.shared.isIdleTimerDisabled = false
        print("Victory!")
//        gameState!.restart()
    }
    
    func endGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        gameView?.removeFromSuperview()
        gameView = nil
        gameState = nil
        gameRunning = false
    }
}
