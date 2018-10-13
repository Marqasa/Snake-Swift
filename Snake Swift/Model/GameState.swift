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
    
    var fruitID: Int?
    
    // Subscript for getting or setting board tiles
    subscript(i: Int) -> Tile {
        get {
            return board[i]
        }
        set {
            board[i] = newValue
        }
    }
    
    var headID: Int {
        return snake[0]
    }
    
    var tailID: Int {
        return snake.endIndex - 1
    }
    
    // Determines fruit distance from head
    //TODO: Convert to Optional Int
    var fruitDistance: Int {
        if fruitID != nil {
        let rowDistance = abs(board[fruitID!].row - board[headID].row)
        let colDistance = abs(board[fruitID!].col - board[headID].col)
        return rowDistance + colDistance
        } else { return 0 }
    }
    
    // Returns true if the snake is smaller than the playable board space
    var boardHasSpace: Bool {
        return snake.count < (board.count - (boardCol * 4) + 4)
    }
    
    // Getter returns head TileType. Setter sets head TileType only if newValue is a .head case
    var head: TileType {
        get {
            return board[headID].type
        }
        set {
            switch newValue {
            case .head(.up, _), .head(.right, _), .head(.down, _), .head(.left, _):
                board[headID].type = newValue
            default:
                break
            }
        }
    }
    
    // Getter returns tail TileType. Setter sets tail TileType only if newValue is a .tail case
    var tail: TileType {
        get {
            return board[tailID].type
        }
        set {
            switch newValue {
            case .tail(.up, _), .tail(.right, _), .tail(.down, _), .tail(.left, _):
                board[tailID].type = newValue
            default:
                break
            }
        }
    }
    
    // Computed Properties to determine fruit location relative to head (Ternary Conditional Operator)
    var fruitIsBelow: Bool { return fruitID != nil ? board[fruitID!].row > board[headID].row : false }
    
    var fruitIsToTheRight: Bool { return fruitID != nil ? board[fruitID!].col > board[headID].col : false }
    
    var fruitIsAbove: Bool { return fruitID != nil ? board[fruitID!].row < board[headID].row : false }
    
    var fruitIsToTheLeft: Bool { return fruitID != nil ? board[fruitID!].col < board[headID].col : false }
    
    // Computed Properties to determine tail location relative to head
    var tailIsBelow: Bool { return board[tailID].row > board[headID].row }
    
    var tailIsToTheRight: Bool { return board[tailID].col > board[headID].col }
    
    var tailIsAbove: Bool { return board[tailID].row < board[headID].row }
    
    var tailIsToTheLeft: Bool { return board[tailID].col < board[headID].col }
    
    // Check for all empty tiles
    mutating func checkEmptyTiles() {
        for (i, e) in board.enumerated() {
            if e.type == .empty {
                emptyTiles.insert(i)
            } else {
                emptyTiles.remove(i)
            }
        }
    }
    
    // Update the game state (move/grow the snake and spawn a new fruit if neccessary)
    mutating func update(live: Bool) {
        
        // Remember tail state
        var tempTail = tail
        
        // Update old and new tile properties:
        func updateTileProperties(from oldID: Int, to newID: Int) {
            
            switch board[oldID].type {
            case let .head(headDirection, headColor):
                
//                headID = newID
                
                switch board[newID].type {
                case let .tail(tailDirection, tailColor):
                    board[newID].type = .dual(.head(headDirection, headColor), .tail(tailDirection, tailColor))
                case let .fruit(fruitColor):
                    board[newID].type = .dual(.head(headDirection, fruitColor), .fruit(fruitColor))
                case .wall, .body:
                    gameOver = true
                default:
                    board[newID].type = .head(headDirection, headColor)
                }
                
            case .body:
                
                // Force unwrapped optionals
                let color = board[newID].type.color()!
                switch board[newID].type.direction()! {
                case .up:
                    if oldID == newID + boardCol {
                        board[newID].type = .body(.up, .upRight, color)
                    } else if oldID == newID + boardRow {
                        board[newID].type = .body(.up, .upDown, color)
                    } else {
                        board[newID].type = .body(.up, .upLeft, color)
                    }
                case .right:
                    if oldID == newID - boardRow {
                        board[newID].type = .body(.right, .upRight, color)
                    } else if oldID == newID - boardCol {
                        board[newID].type = .body(.right, .rightLeft, color)
                    } else {
                        board[newID].type = .body(.right, .rightDown, color)
                    }
                case .down:
                    if oldID == newID + boardCol {
                        board[newID].type = .body(.down, .rightDown, color)
                    } else if oldID == newID - boardCol {
                        board[newID].type = .body(.down, .downLeft, color)
                    } else {
                        board[newID].type = .body(.down, .upDown, color)
                    }
                case .left:
                    if oldID == newID + boardRow {
                        board[newID].type = .body(.left, .downLeft, color)
                    } else if oldID == newID + boardCol {
                        board[newID].type = .body(.left, .rightLeft, color)
                    } else {
                        board[newID].type = .body(.left, .upLeft, color)
                    }
                }
            case .tail:
                
                let color = board[newID].type.color()!
                
                switch head {
                    
                    // If the snake ate a piece of fruit:
                case let .dual(.head(headDirection, headColor), .fruit):
                    head = .head(headDirection, headColor)
                    snake.append(oldID)
                    fruitID = 0
                    if live {
                        newFruit()
                        if fruitID != nil { needsDisplay.insert(fruitID!) }
                        shortestPath = Path()
                    }
                    
                    // Else move the tail:
                default:
                    if boardHasSpace && fruitID == 0 {
                        snake.append(oldID)
                    } else {
//                        tailID = newID
                        if let direction = board[newID].type.direction() {
                            board[newID].type = .tail(direction, color)
                        }
                        board[oldID].type = .empty
                    }
                }
                
            case let .dual(.head(headDirection, _), .tail(_, tailColor)):
//                tailID = newID
                if let tailDirection = board[newID].type.direction() {
                    board[newID].type = .tail(tailDirection, tailColor)
                }
                board[oldID].type = .head(headDirection, tailColor)
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
            case .up:
                snake[i] -= boardRow
            case .right:
                snake[i] += boardCol
            case .down:
                snake[i] += boardRow
            case .left:
                snake[i] -= boardCol
            }
            
            // Update properties for both old and new tiles:
            updateTileProperties(from: tileID, to: snake[i])
        }
    }
    
    // Add a new fruit to the board and return its ID
    mutating func newFruit() {
        
        // Only add a new fruit if there is still space on the board
        //TODO: Maintain emptyTiles and use it as the check for game over instead of boardHasSpace
        if boardHasSpace {
            
            // Check for empty tiles
            checkEmptyTiles()
            
            // Choose an empty tile at random and spawn the fruit there
            fruitID = emptyTiles.randomElement()
            if fruitID != nil {
                let hue = CGFloat(arc4random_uniform(100)) / 100
                let color = UIColor(hue: hue, saturation: 0.5, brightness: 0.9, alpha: 1)
                board[fruitID!].type = .fruit(color)
            }

        } else {
            //TODO: Add victory screen
            print("You Win!")
        }
    }
}
