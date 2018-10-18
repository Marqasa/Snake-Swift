//
//  SnakeLogic.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 18/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import Foundation

struct SnakeLogic {
    var sortedDirections = [Direction]()
    
    // Sort directions based on fruit location:
    mutating func sortDirections(state: GameState) {
        sortedDirections = Direction.allCases.sorted {
            switch ($0, $1) {
            case (.right, .up):
                return state.fruitIsToTheRight || state.fruitIsBelow ? true : false
            case (.down, .right):
                return state.fruitIsBelow || state.fruitIsToTheLeft ? true : false
            case (.left, .down):
                return state.fruitIsToTheLeft || state.fruitIsAbove ? true : false
            case (.left, .up):
                return state.fruitIsToTheLeft || state.fruitIsBelow ? true : false
            case (.down, .up):
                return state.fruitIsBelow
            case (.left, .right):
                return state.fruitIsToTheLeft
            default:
                return false
            }
        }
    }
}
