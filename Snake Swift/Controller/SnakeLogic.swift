//
//  SnakeLogic.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 18/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import UIKit

struct SnakeLogic {
    var shortestPath: Path?
    
    // Get new direction:
    mutating func getNewDirection(state: GameState) -> Direction {
        if shortestPath?.route.isEmpty ?? true {
            var fruitSearch = [Path.init(state: state)]
            var tailSearch = [Path]()
            let duration = Double(state.fruitlessMoves) * 0.005
            let timeLimit = DateInterval(start: Date(), duration: duration)
            findPath(&fruitSearch, &tailSearch, timeLimit)
        }
        if shortestPath != nil {
            let newDirection = shortestPath!.route[0]
            shortestPath!.route.remove(at: 0)
            if shortestPath!.route.isEmpty { shortestPath = nil }
            return newDirection
        }
        var safeDirections: Set<Direction> = [.up, .right, .down, .left]
        
        for direction in safeDirections {
            var checkedTiles = Set<Int>()
            let startingTile: Int = {
                switch direction {
                case .up:       return state.headID - state.row
                case .right:    return state.headID + state.col
                case .down:     return state.headID + state.row
                case .left:     return state.headID - state.col
                default:        fatalError("Invalid direction.")
                }
            }()
            if !checkTile(startingTile, direction, state, &checkedTiles) {
                safeDirections.remove(direction)
            }
        }
        return self.getDirectionFromFruit(state: state, safeDirections: safeDirections)
        
    }
    
    private func checkTile(_ tileID: Int, _ direction: Direction, _ state: GameState, _ checkedTiles: inout Set<Int>) -> Bool {
        if checkedTiles.contains(tileID) { return false } else { checkedTiles.insert(tileID) }
        
        if let tile = state[tileID] {
            switch tile.kind {
            case .wall, .body, .head:
                return false
            case .tail:
                return true
            case .fruit:
                break
            default:
                switch state.tailKind.direction() {
                case .up?:
                    let safe = state.tailID - 1 // The tile below the tail
                    
                    if tileID - state.row == safe || tileID + state.col == safe || tileID - state.col == safe {
                        return true
                    }
                case .right?:
                    let safe = state.tailID + state.col // The tile to the right of the tail
                    
                    if tileID + state.row == safe || tileID - state.row == safe || tileID + state.col == safe {
                        return true
                    }
                case .down?:
                    
                    let safe = state.tailID + 1 // The tile above the tail
                    
                    if tileID - state.col == safe || tileID + state.col == safe || tileID + state.row == safe {
                        return true
                    }
                case .left?:
                    
                    let safe = state.tailID - state.col // The tile to the left of the tail
                    
                    if tileID - state.col == safe || tileID - state.row == safe || tileID + state.row == safe {
                        return true
                    }
                default:
                    break
                }
            }
        }
        // Check the tile above
        if checkTile(tileID - state.row, direction, state, &checkedTiles) { return true }
        
        // Check the tile to the right
        if checkTile(tileID + state.col, direction, state, &checkedTiles) { return true }
        
        // Check the tile below
        if checkTile(tileID + state.row, direction, state, &checkedTiles) { return true }
        
        // Check the tile to the left
        if checkTile(tileID - state.col, direction, state, &checkedTiles) { return true }
        
        // This direction is not safe
        return false
    }
    
    // Choose new direction based on fruit direction and current direction:
    private func getDirectionFromFruit(state: GameState, safeDirections: Set<Direction>) -> Direction {
        let direction = state.head.kind.direction()!
        switch state.fruitDirection {
        case .up?:
            if safeDirections.contains(.up) { return .up }
            if safeDirections.contains(.left) && safeDirections.contains(.right) { return arc4random_uniform(2) > 0 ? .left : .right }
            if safeDirections.contains(.left) { return .left }
            if safeDirections.contains(.right) { return .right }
            return .down
        case .upRight?:
            if safeDirections.contains(.up) && safeDirections.contains(.right) && (direction == .up || direction == .right) { return direction }
            if safeDirections.contains(.up) { return .up }
            if safeDirections.contains(.right) { return .right }
            if safeDirections.contains(.left) && safeDirections.contains(.down) && (direction == .left || direction == .down) { return direction }
            if safeDirections.contains(.left) { return .left }
            return .down
        case .upLeft?:
            if safeDirections.contains(.up) && safeDirections.contains(.left) && (direction == .up || direction == .left) { return direction }
            if safeDirections.contains(.up) { return .up }
            if safeDirections.contains(.left) { return .left }
            if safeDirections.contains(.right) && safeDirections.contains(.down) && (direction == .right || direction == .down) { return direction }
            if safeDirections.contains(.right) { return .right }
            return .down
        case .right?:
            if safeDirections.contains(.right) { return .right }
            if safeDirections.contains(.up) && safeDirections.contains(.down) { return arc4random_uniform(2) > 0 ? .up : .down }
            if safeDirections.contains(.up) { return .up }
            if safeDirections.contains(.down) { return .down }
            return .left
        case .left?:
            if safeDirections.contains(.left) { return .left }
            if safeDirections.contains(.up) && safeDirections.contains(.down) { return arc4random_uniform(2) > 0 ? .up : .down }
            if safeDirections.contains(.up) { return .up }
            if safeDirections.contains(.down) { return .down }
            return .right
        case .downRight?:
            if safeDirections.contains(.down) && safeDirections.contains(.right) && (direction == .down || direction == .right) { return direction }
            if safeDirections.contains(.down) { return .down }
            if safeDirections.contains(.right) { return .right }
            if safeDirections.contains(.up) && safeDirections.contains(.left) && (direction == .up || direction == .left) { return direction }
            if safeDirections.contains(.up) { return .up }
            return .left
        case .downLeft?:
            if safeDirections.contains(.down) && safeDirections.contains(.left) && (direction == .down || direction == .left) { return direction }
            if safeDirections.contains(.down) { return .down }
            if safeDirections.contains(.left) { return .left }
            if safeDirections.contains(.up) && safeDirections.contains(.right) && (direction == .up || direction == .right) { return direction }
            if safeDirections.contains(.up) { return .up }
            return .right
        case .down?:
            if safeDirections.contains(.down) { return .down }
            if safeDirections.contains(.left) && safeDirections.contains(.right) { return arc4random_uniform(2) > 0 ? .left : .right }
            if safeDirections.contains(.left) { return .left }
            if safeDirections.contains(.right) { return .right }
            return .up
        case nil:
            break
        }
        return direction
    }
    
    // Find path exstensive search
    private mutating func findPath(_ fruitSearch: inout [Path], _ tailSearch: inout [Path], _ timeLimit: DateInterval) {
        if Date() > timeLimit.end {
            return
        }
        
        // Check tile in direction:
        func searchPath(_ path: Path, direction: Direction) {
            var newPath = path
            let tileID: Int = {
                switch direction {
                case .up:       return path.up
                case .right:    return path.right
                case .down:     return path.down
                case .left:     return path.left
                default:        fatalError("Invalid direction.")
                }
            }()
            
            // Check tile type:
            switch path.state[tileID]!.kind {
            case .wall, .body:
                return
            case .fruit:
                newPath.findsFruit = true
            case .tail:
                if newPath.state.fruitID == nil {
                    newPath.findsFruit = true
                    newPath.findsTail = true
                } else if newPath.findsFruit {
                    newPath.findsTail = true
                }
            default:
                break
            }
            
            //TODO: Ensure final two squares can be moved next each other regardless of which square spawns the fruit
            
            newPath.route.append(direction)
            newPath.state.headKind = .head(direction, UIColor.red)
            _ = newPath.state.update(live: false)
            
            if newPath.findsFruit {
                tailSearch.append(newPath)
            } else {
                fruitSearch.append(newPath)
            }
        }
        
        if !tailSearch.isEmpty {
            var last = 0
            for (i, path) in tailSearch.enumerated() {
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
            var last = 0
            for (i, path) in fruitSearch.enumerated() {
                if (fruitSearch.count == 1 && !path.route.isEmpty) || path.depth > path.state.snake.count * 8 {
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
        }
        findPath(&fruitSearch, &tailSearch, timeLimit)
    }
}
