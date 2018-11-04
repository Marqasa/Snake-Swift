//
//  Path.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 07/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import Foundation

class Path {
    static var maxID: Int = 0
    let id: Int
    var state: GameState
    var route = [Direction]()
    var next: Path?
    
    var headID: Int { return state.headID }
    var depth: Int { return route.count }
    var absFruitDistance: Int { return (state.fruitDistance ?? 0) + depth }
    var up:     Int { return headID - state.row }
    var right:  Int { return headID + state.col }
    var down:   Int { return headID + state.row }
    var left:   Int { return headID - state.col }
    
    init(state: GameState, route: [Direction], next: Path?) {
        self.id = Path.maxID + 1
        self.state = state
        self.route = route
        self.next = next
        Path.maxID = self.id
    }
}
