//
//  Path.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 07/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import Foundation

struct Path {
    var route = [Direction]()
    var state = GameState()
    var findsFruit = false
    var findsTail = false
    
    var id: Int {
        return state.headID
    }
    var depth: Int {
        return route.count
    }
    
    var up: Int { return id - boardRow }
    var right: Int { return id + boardCol }
    var down: Int { return id + boardRow }
    var left: Int { return id - boardCol }
}
