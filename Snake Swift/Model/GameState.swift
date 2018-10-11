//
//  GameState.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 07/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import Foundation
//TODO: Update fruitHue so UIKit is not needed
import UIKit

struct GameState {
    var board = [Tile]()
    var snake = [Int]()
    var needsDisplay = Set<Int>()
    var emptyTiles = Set<Int>()
    var gameOver = false
    
    var headID = 0
    var tailID = 0
    var fruitID = 0
    
    // Determines fruit distance from head
    var fruitDistance: Int {
        let rowDistance = abs(board[fruitID].row - board[headID].row)
        let colDistance = abs(board[fruitID].col - board[headID].col)
        return rowDistance + colDistance
    }
    
    // Returns true if the snake is smaller than the playable board space
    var boardHasSpace: Bool {
        return snake.count < (board.count - (boardCol * 4) + 4)
    }
    
    // Getter returns head tile type. Setter sets head tile type only if newValue is of type .Head()
    var head: TileType {
        get {
            return board[snake[0]].type
        }
        set {
            switch newValue {
            case .Head(.Up), .Head(.Right), .Head(.Down), .Head(.Left):
                board[snake[0]].type = newValue
            default:
                break
            }
        }
    }
    
    var tail: TileType {
        get {
            return board[snake.endIndex - 1].type
        }
        set {
            switch newValue {
            case .Tail(.Up), .Tail(.Right), .Tail(.Down), .Tail(.Left):
                board[snake.endIndex - 1].type = newValue
            default:
                break
            }
        }
    }
    
    var fruitIsBelow: Bool {
        return board[fruitID].row > board[headID].row
    }
    
    var fruitIsToTheRight: Bool {
        return board[fruitID].col > board[headID].col
    }
    
    var fruitIsAbove: Bool {
        return board[fruitID].row < board[headID].row
    }
    
    var fruitIsToTheLeft: Bool {
        return board[fruitID].col < board[headID].col
    }
    
    var tailIsBelow: Bool {
        return board[tailID].row > board[headID].row
    }
    
    var tailIsToTheRight: Bool {
        return board[tailID].col > board[headID].col
    }
    
    var tailIsAbove: Bool {
        return board[tailID].row < board[headID].row
    }
    
    var tailIsToTheLeft: Bool {
        return board[tailID].col < board[headID].col
    }
    
    // Update set of empty tiles:
    mutating func checkEmptyTiles() {
        for (i, e) in board.enumerated() {
            if e.type == .Empty {
                emptyTiles.insert(i)
            } else {
                emptyTiles.remove(i)
            }
        }
    }
    
    mutating func update(live: Bool) {
        
        // Remember tail state
        var tempTail = tail
        
        // Update old and new tile properties:
        func updateTileProperties(from oldID: Int, to newID: Int) {
            
            switch board[oldID].type {
            case .Head(let headDirection):
                
                headID = newID
                
                switch board[newID].type {
                case .Tail(let tailDirection):
                    board[newID].type = .Dual(.Head(headDirection), .Tail(tailDirection))
                case .Fruit:
                    board[newID].type = .Dual(.Head(headDirection), .Fruit)
                case .Wall, .Body(_, _):
                    gameOver = true
                default:
                    board[newID].type = .Head(headDirection)
                }
                
            case .Body(_, _):
                
                // Force unwrapped optional
                switch board[newID].type.direction()! {
                case .Up:
                    if oldID == newID + boardCol {
                        board[newID].type = .Body(.Up, .UpRight)
                    } else if oldID == newID + boardRow {
                        board[newID].type = .Body(.Up, .UpDown)
                    } else {
                        board[newID].type = .Body(.Up, .UpLeft)
                    }
                case .Right:
                    if oldID == newID - boardRow {
                        board[newID].type = .Body(.Right, .UpRight)
                    } else if oldID == newID - boardCol {
                        board[newID].type = .Body(.Right, .RightLeft)
                    } else {
                        board[newID].type = .Body(.Right, .RightDown)
                    }
                case .Down:
                    if oldID == newID + boardCol {
                        board[newID].type = .Body(.Down, .RightDown)
                    } else if oldID == newID - boardCol {
                        board[newID].type = .Body(.Down, .DownLeft)
                    } else {
                        board[newID].type = .Body(.Down, .UpDown)
                    }
                case .Left:
                    if oldID == newID + boardRow {
                        board[newID].type = .Body(.Left, .DownLeft)
                    } else if oldID == newID + boardCol {
                        board[newID].type = .Body(.Left, .RightLeft)
                    } else {
                        board[newID].type = .Body(.Left, .UpLeft)
                    }
                }
            case .Tail(_):
                
                switch head {
                    
                    // If the snake ate a piece of fruit:
                case .Dual(.Head(let headDirection), .Fruit):
                    head = .Head(headDirection)
                    snake.append(oldID)
                    fruitID = 0
                    if live {
                        needsDisplay.insert(newFruit())
                        shortestPath = Path()
                    }
                    
                    // Else move the tail:
                default:
                    if boardHasSpace && fruitID == 0 {
                        snake.append(oldID)
                    } else {
                        tailID = newID
                        if let direction = board[newID].type.direction() {
                            board[newID].type = .Tail(direction)
                        }
                        board[oldID].type = .Empty
                    }
                }
                
            case .Dual(.Head(let headDirection), .Tail(_)):
                tailID = newID
                if let tailDirection = board[newID].type.direction() {
                    board[newID].type = .Tail(tailDirection)
                }
                board[oldID].type = .Head(headDirection)
            default:
                break
            }
            
            if live {
                needsDisplay.insert(oldID)
                needsDisplay.insert(newID)
            }
        }
        
        // Move the snake to its new postion and update properties for all affected tiles
        for (i, tileID) in snake.enumerated() {
            
             // Get tile direction from tileID
            let direction = board[tileID].type.direction()
            
            // Update snake[i] to contain new tile ID:
            switch direction! {
            case .Up:
                snake[i] -= boardRow
            case .Right:
                snake[i] += boardCol
            case .Down:
                snake[i] += boardRow
            case .Left:
                snake[i] -= boardCol
            }
            
            // Update properties for both old and new tiles:
            updateTileProperties(from: tileID, to: snake[i])
        }
    }
    
    mutating func newFruit() -> Int {
        // Clear path when a new fruit is spawned
        shortestPath = Path()
        
        // Only add a new fruit if there is still space on the board:
        if boardHasSpace {
            checkEmptyTiles()
            
            if let i = emptyTiles.randomElement() {
                board[i].type = .Fruit
                fruitHue = CGFloat(arc4random_uniform(100) / 100)
                fruitID = i
                return i
                
            } else {
                fruitID = 0
                return 0
            }

        } else {
            //TODO: Add victory screen
            print("You Win!")
            fruitID = 0
            return 0
        }
    }
}
