//
//  Path.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 07/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import Foundation

struct Path {
    var state: GameState
    var route = [Direction]()
    var id: Int { return state.headID }
    var kind: Tile.Kind { return state.headKind }
    var depth: Int { return route.count }
    var absFruitDistance: Int { return (state.fruitDistance ?? 0) + depth }
    var up:     Int { return id - state.row }
    var right:  Int { return id + state.col }
    var down:   Int { return id + state.row }
    var left:   Int { return id - state.col }
    
    init(state: GameState) {
        self.state = state
    }
}
