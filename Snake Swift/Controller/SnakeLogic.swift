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
            let pathList = PathList()
            Path.maxID = 0
            pathList.insert(path: Path(state: state, route: [Direction](), next: nil))
            let duration = min(Double(state.fruitlessMoves) * 0.003, 3)
            let timeLimit = DateInterval(start: Date(), duration: duration)
            findPath(pathList, timeLimit)
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
                // Check if the tail will be adjacent in 1 moves time (only if the fruit is still on the board, else the tail is assumed to remain still)
                if state.fruitID != nil {
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
    private mutating func findPath(_ pathList: PathList, _ timeLimit: DateInterval) {
        
        // Search path for fruit
        func searchPath(_ path: Path,_ direction: Direction) -> Bool {
            let newPath = Path(state: path.state, route: path.route, next: nil)
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
            pathList.insertInOrder(path: newPath)
            return false
        }

        while !pathList.isEmpty {
            let path = pathList.first!
            
            if shortestPath != nil { return } // Once a path is found return
            if path.next == nil && !path.route.isEmpty { shortestPath = path; return } // If there is only one option take it
            if Date() > timeLimit.end { return } // Give up if the search takes too long
            
            if searchPath(path, .up)    { return }
            if searchPath(path, .right) { return }
            if searchPath(path, .down)  { return }
            if searchPath(path, .left)  { return }
            
            pathList.delete(id: path.id) // Delete searched path from list
        }
    }
}
