//
//  TileState.swift
//  Snake Swift
//
//  Created by Sam Louis Walker-Penn on 07/10/2018.
//  Copyright © 2018 Sam Louis Walker-Penn. All rights reserved.
//

import Foundation

struct Tile {
    var type = TileType.Empty
    var isHead = false, isBody = false, isTail = false, isWall = false, isFruit = false, wasTail = false
    var col = 0, row = 0
    var direction = Direction.Up
    var bodyShape = BodyShape.RightLeft
}
