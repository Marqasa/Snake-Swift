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
    
    mutating func update(live: Bool) {
        
        // Remember initial tail direction
        var tailDirection = Direction.Up
        if let tail = snake.last {
            tailDirection = board[tail].direction
        }
        
        // Update old and new tile properties:
        func updateTileProperties(from oldID: Int, to newID: Int) {
            
            if board[oldID].isHead && !board[oldID].isTail {
                
                board[newID].isHead = true
                board[newID].direction = board[oldID].direction
                board[oldID].isHead = false
                
            } else if board[oldID].isBody {
                
                if live {
                    switch board[newID].direction {
                    case .Up:
                        if oldID == newID + boardCol {
                            board[newID].bodyShape = .UpRight
                        } else if oldID == newID + boardRow {
                            board[newID].bodyShape = .UpDown
                        } else {
                            board[newID].bodyShape = .UpLeft
                        }
                    case .Right:
                        if oldID == newID - boardRow {
                            board[newID].bodyShape = .UpRight
                        } else if oldID == newID - boardCol {
                            board[newID].bodyShape = .RightLeft
                        } else {
                            board[newID].bodyShape = .RightDown
                        }
                    case .Down:
                        if oldID == newID + boardCol {
                            board[newID].bodyShape = .RightDown
                        } else if oldID == newID - boardCol {
                            board[newID].bodyShape = .DownLeft
                        } else {
                            board[newID].bodyShape = .UpDown
                        }
                    case .Left:
                        if oldID == newID + boardRow {
                            board[newID].bodyShape = .DownLeft
                        } else if oldID == newID + boardCol {
                            board[newID].bodyShape = .RightLeft
                        } else {
                            board[newID].bodyShape = .UpLeft
                        }
                    }
                }
                
                board[newID].isBody = true
                if !board[snake[0]].isFruit {
                    board[oldID].isBody = false
                }
                
            } else if board[oldID].isTail {
                
                // If the snake ate a piece of fruit:
                if board[snake[0]].isFruit {
                    
                    // Remove the fruit
                    board[snake[0]].isFruit = false
                    
                    // Grow the snake:
                    snake.append(oldID)
                    
                    if live {
                        needsDisplay.insert(newFruit())
                    }
                    
                    // Else move the tail:
                } else {
                    board[newID].isTail = true
                    board[oldID].isTail = false
                }
            }
            
            if live {
                needsDisplay.insert(oldID)
                needsDisplay.insert(newID)
            }
        }
        
        // Move the snake to its new postion and update properties for all affected tiles
        for (i, tileID) in snake.enumerated() {
            
            /*
             Get tile direction from tileID. tailFacing is used to ensure the tail moves in the correct direction
             in situations where the head changes the direction of the tail before it has had a chance to move.
             */
            var direction = board[tileID].direction
            if board[tileID].isTail {
                direction = tailDirection
            }
            
            // Update snake[i] to contain new tile ID:
            switch direction {
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
        shortestPath = []
        
        // Only add a new fruit if there is still space on the board:
        if snake.count < (board.count - (boardCol * 4) + 4) {
            var isSet = false
            repeat {
                let i = Int(arc4random()) % board.count
                
                // Only add the fruit if the tile is free:
                if !board[i].isWall && !board[i].isHead && !board[i].isBody && !board[i].isTail {
                    board[i].isFruit = true
                    fruitHue = CGFloat(arc4random_uniform(100) / 100)
                    isSet = true
                    return i
                }
            } while !isSet
        } else {
            //TODO: Add victory screen
            print("You Win!")
            return 0
        }
    }
}
