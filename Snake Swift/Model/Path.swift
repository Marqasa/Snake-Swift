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
    
    init(state: GameState) {
        self.state = state
    }
    
    var route = [Direction]()
    var findsFruit = false
    var findsTail = false
    
    var id: Int {
        return state.headID
    }
    var depth: Int {
        return route.count
    }
    
    var up:     Int { return id - state.row }
    var right:  Int { return id + state.col }
    var down:   Int { return id + state.row }
    var left:   Int { return id - state.col }
}
