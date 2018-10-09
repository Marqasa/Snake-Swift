//
//  Path.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 07/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import Foundation

struct Path {
    static var maxNumberSafePaths = 5
    static var currentNumberSafePaths = 0
    
    var route = [Direction]()
    var moves = 0
    var findsTail = false
    var findsFruit = false
    var findsFruitAndTail = false
    
    mutating func move() {
        if !findsFruit {
            moves += 1
        }
    }
}
