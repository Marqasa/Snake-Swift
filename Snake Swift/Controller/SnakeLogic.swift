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
    var logicCycles = 0
    
    // Get new direction:
    mutating func getNewDirection(state: GameState) -> Direction {
        if shortestPath?.route.isEmpty ?? true {
            var pathsToSearch = [Path.init(state: state)]
            let duration = min(Double(state.fruitlessMoves) * 0.002, 2)
            let timeLimit = DateInterval(start: Date(), duration: duration)
            findPath(&pathsToSearch, timeLimit)
        }
        if shortestPath != nil {
            let newDirection = shortestPath!.route[0]
            shortestPath!.route.remove(at: 0)
            if shortestPath!.route.isEmpty { shortestPath = nil }
            return newDirection
        }
        return self.getDirectionFromFruit(state: state, safeDirections: getSafeDirections(state))
        
    }
    
    private func getSafeDirections(_ state: GameState) -> Set<Direction> {
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
            if !checkTile(startingTile, state, &checkedTiles) {
                safeDirections.remove(direction)
            }
        }
        return safeDirections
    }
    
    // Check tile has a safe path to the tail
    private func checkTile(_ tileID: Int, _ state: GameState, _ checkedTiles: inout Set<Int>) -> Bool {
        if checkedTiles.contains(tileID) { return false } else { checkedTiles.insert(tileID) }
        
        if let tile = state[tileID] {
            switch tile.kind {
            case .wall, .head, .body: return false
            case .tail: return true
            case .fruit: break
            default:
                // Check if the tail will be adjacent in 1 moves time
                let nextTailID: Int = {
                    switch state.tailKind.direction! {
                    case .up:       return state.tailID - state.row
                    case .right:    return state.tailID + state.col
                    case .down:     return state.tailID + state.row
                    case .left:     return state.tailID - state.col
                    default:        fatalError("Invalid direction.")
                    }
                }()
                if nextTailID == tileID - state.row || nextTailID == tileID + state.row || nextTailID == tileID - state.col || nextTailID == tileID + state.col {
                    return true
                }
            }
        }
        
        // Check the tile above
        if checkTile(tileID - state.row, state, &checkedTiles) { return true }
        
        // Check the tile to the right
        if checkTile(tileID + state.col, state, &checkedTiles) { return true }
        
        // Check the tile below
        if checkTile(tileID + state.row, state, &checkedTiles) { return true }
        
        // Check the tile to the left
        if checkTile(tileID - state.col, state, &checkedTiles) { return true }
        
        // This tile is not safe
        return false
    }
    
    // Choose new direction from all safe options based on fruit direction:
    private func getDirectionFromFruit(state: GameState, safeDirections: Set<Direction>) -> Direction {
        let direction = state.head.kind.direction!
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
    private mutating func findPath(_ pathsToSearch: inout [Path], _ timeLimit: DateInterval) {
        
        // Search path for fruit
        func searchPath(_ path: Path, direction: Direction) -> Bool {
            logicCycles += 1
            var newPath = path
            newPath.state = GameState(fromState: path.state)
            newPath.route.append(direction)
            newPath.state.headDirection = direction
            let result = newPath.state.update()
            
            switch result {
            case .gameOver: return false
            case .fruitEaten:
                for direction in Set<Direction>(arrayLiteral: .up, .right, .down, .left) {
                    var checkedTiles = Set<Int>()
                    let startingTile: Int = {
                        switch direction {
                        case .up:       return newPath.up
                        case .right:    return newPath.right
                        case .down:     return newPath.down
                        case .left:     return newPath.left
                        default:        fatalError("Invalid direction.")
                        }
                    }()
                    if checkTile(startingTile, newPath.state, &checkedTiles) {
                        shortestPath = newPath
                        return true
                    }
                }
                return false
            default: break
            }
            pathsToSearch.append(newPath)
            return false
        }
        
        if !pathsToSearch.isEmpty {
            var pathsSearched = 0
            for path in pathsToSearch where path.absFruitDistance <= pathsToSearch[0].absFruitDistance {
                if shortestPath != nil || Date() > timeLimit.end { return }
                if (pathsToSearch.count == 1 && !path.route.isEmpty) || path.depth > path.state.snake.count * 8 {
                    shortestPath = path; return
                }
                if searchPath(path, direction: .up) { return }
                if searchPath(path, direction: .right) { return }
                if searchPath(path, direction: .down) { return }
                if searchPath(path, direction: .left) { return }
                pathsSearched += 1
            }
            pathsToSearch.removeSubrange(0..<pathsSearched) // Remove searched paths
            pathsToSearch.sort { $0.absFruitDistance < $1.absFruitDistance }
        }
        findPath(&pathsToSearch, timeLimit)
    }
}
